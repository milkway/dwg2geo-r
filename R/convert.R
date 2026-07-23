#' Convert a DWG drawing to GeoJSON
#'
#' Reads an AutoCAD 2013+ (`AC1027`) DWG file and converts its model-space
#' entities to a GeoJSON `FeatureCollection`, entirely in-process — no CAD
#' software, LibreDWG, or GDAL required. Every feature carries resolved CAD
#' style metadata (`layer`, `color_rgb`, `color_index`, `linetype`,
#' `lineweight_mm`, text properties), and skipped or failed entities are
#' reported with reasons.
#'
#' Coordinates are kept in the drawing's **local** system: dwg2geo never
#' guesses a coordinate reference system. Georeference the result yourself —
#' e.g. read it with [dwg_as_sf()], set the known CRS with
#' `sf::st_set_crs()`, and reproject with `sf::st_transform()`.
#'
#' The conversion is deterministic: the same bytes always produce
#' byte-identical GeoJSON on a given platform.
#'
#' @param path Path to a `.dwg` file.
#' @param polygonize_closed Convert closed polylines to polygons instead of
#'   line strings. Defaults to `FALSE`.
#' @param curve_tolerance Maximum sagitta error, in drawing units, allowed
#'   when tessellating arcs, circles, ellipses, and splines. `NULL` (the
#'   default) uses the converter's default of `0.05`.
#' @param quiet Suppress progress messages. Defaults to `FALSE`.
#'
#' @return A list of class `"dwg2geo_result"` with elements:
#' \describe{
#'   \item{`geojson`}{The `FeatureCollection` as a JSON string (local
#'     drawing coordinates).}
#'   \item{`feature_count`, `model_space_entities`}{Totals.}
#'   \item{`converted`, `skipped`, `failed`}{Tibbles of per-entity-type
#'     outcomes; `skipped`/`failed` include a `reason` column.}
#'   \item{`warnings`}{Character vector of conversion warnings.}
#'   \item{`bbox`}{Numeric `c(xmin, ymin, xmax, ymax)` in drawing units, or
#'     `NULL`.}
#'   \item{`source_sha256`}{SHA-256 of the input bytes (audit trail).}
#' }
#'
#' @examples
#' \dontrun{
#' result <- dwg_convert("drawing.dwg")
#' result$feature_count
#' result$converted
#'
#' # to sf, with an explicitly known CRS:
#' shapes <- dwg_as_sf(result) |>
#'   sf::st_set_crs(31983) |>
#'   sf::st_transform(4326)
#' }
#'
#' @export
dwg_convert <- function(path,
                        polygonize_closed = FALSE,
                        curve_tolerance = NULL,
                        quiet = FALSE) {
  check_path(path)
  check_bool(polygonize_closed)
  check_bool(quiet)
  if (!is.null(curve_tolerance)) {
    if (!is.numeric(curve_tolerance) || length(curve_tolerance) != 1L ||
        !is.finite(curve_tolerance) || curve_tolerance <= 0) {
      cli::cli_abort(
        "{.arg curve_tolerance} must be a single positive number, not {.obj_type_friendly {curve_tolerance}}."
      )
    }
    curve_tolerance <- as.double(curve_tolerance)
  }

  bytes <- readBin(path, what = "raw", n = file.size(path))
  if (!quiet) {
    cli::cli_inform(c(
      "i" = "Converting {.file {path}} ({prettyunits_bytes(length(bytes))})..."
    ))
  }

  outcome <- convert_impl(bytes, polygonize_closed, curve_tolerance)
  if (!is.null(outcome$error)) {
    cli::cli_abort(
      c(
        "Conversion failed for {.file {path}}.",
        "x" = outcome$error
      ),
      class = "dwg2geo_convert_error"
    )
  }
  json <- outcome$json

  raw_result <- jsonlite::fromJSON(json, simplifyVector = TRUE)
  result <- structure(
    list(
      geojson = raw_result$geojson,
      feature_count = as.integer(raw_result$feature_count),
      model_space_entities = as.integer(raw_result$model_space_entities),
      converted = outcome_tibble(raw_result$converted),
      skipped = outcome_tibble(raw_result$skipped),
      failed = outcome_tibble(raw_result$failed),
      warnings = as.character(raw_result$warnings %||% character()),
      bbox = if (is.null(raw_result$bbox)) NULL else as.double(raw_result$bbox),
      source_sha256 = raw_result$source_sha256
    ),
    class = "dwg2geo_result"
  )

  if (!quiet) {
    cli::cli_inform(c(
      "v" = "Converted {result$feature_count} feature{?s} from {result$model_space_entities} model-space entit{?y/ies}."
    ))
    n_skipped <- sum(result$skipped$count)
    if (n_skipped > 0) {
      cli::cli_inform(c("!" = "Skipped {n_skipped} entit{?y/ies}; see {.code $skipped} for reasons."))
    }
  }

  result
}

#' Version of the embedded conversion core
#'
#' @return A string: the version of the Rust `dwg2geo` crate compiled into
#'   this package.
#' @examples
#' dwg_core_version()
#' @export
dwg_core_version <- function() {
  core_version_impl()
}

# ---- internal helpers -------------------------------------------------------

outcome_tibble <- function(x) {
  if (is.null(x) || (is.data.frame(x) && nrow(x) == 0) || length(x) == 0) {
    return(tibble::tibble(
      entity_type = character(),
      count = integer(),
      reason = character()
    ))
  }
  out <- tibble::as_tibble(x)
  out$count <- as.integer(out$count)
  if (!"reason" %in% names(out)) out$reason <- NA_character_
  # sample_handles (a list column of example ids) is kept when present.
  out
}

check_path <- function(path, call = rlang::caller_env()) {
  if (!is.character(path) || length(path) != 1L || is.na(path)) {
    cli::cli_abort("{.arg path} must be a single file path.", call = call)
  }
  if (!file.exists(path)) {
    cli::cli_abort("{.file {path}} does not exist.", call = call)
  }
  if (dir.exists(path)) {
    cli::cli_abort("{.file {path}} is a directory, not a DWG file.", call = call)
  }
  invisible(path)
}

check_bool <- function(x, call = rlang::caller_env()) {
  arg <- rlang::caller_arg(x)
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    cli::cli_abort("{.arg {arg}} must be `TRUE` or `FALSE`.", call = call)
  }
  invisible(x)
}

prettyunits_bytes <- function(n) {
  if (n < 1024) return(paste0(n, " B"))
  if (n < 1024^2) return(sprintf("%.1f kB", n / 1024))
  sprintf("%.1f MB", n / 1024^2)
}
