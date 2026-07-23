#' Read a conversion result as an sf object
#'
#' Parses the GeoJSON produced by [dwg_convert()] into an
#' [`sf`][sf::st_sf] data frame. The geometry keeps the drawing's **local**
#' coordinates and carries no CRS — set the known one explicitly with
#' `sf::st_set_crs()` before any reprojection.
#'
#' @param result A `"dwg2geo_result"` object from [dwg_convert()].
#' @param quiet Suppress the reading message. Defaults to `TRUE`.
#'
#' @return An `sf` object with one row per feature and the CAD style
#'   metadata as columns.
#'
#' @examples
#' \dontrun{
#' shapes <- dwg_convert("drawing.dwg") |>
#'   dwg_as_sf() |>
#'   sf::st_set_crs(31983)
#' }
#'
#' @export
dwg_as_sf <- function(result, quiet = TRUE) {
  if (!inherits(result, "dwg2geo_result")) {
    cli::cli_abort(
      "{.arg result} must be a {.cls dwg2geo_result} from {.fun dwg_convert}, not {.obj_type_friendly {result}}."
    )
  }
  rlang::check_installed("sf", reason = "to read the GeoJSON as an sf object.")

  tmp <- tempfile(fileext = ".geojson")
  on.exit(unlink(tmp), add = TRUE)
  writeLines(result$geojson, tmp, useBytes = TRUE)
  sf::st_read(tmp, quiet = quiet)
}
