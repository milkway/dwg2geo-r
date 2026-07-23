#' @export
print.dwg2geo_result <- function(x, ...) {
  cli::cli_h1("dwg2geo conversion")
  cli::cli_bullets(c(
    "*" = "{x$feature_count} feature{?s} from {x$model_space_entities} model-space entit{?y/ies}",
    "*" = "source SHA-256: {.val {substr(x$source_sha256, 1, 12)}}\u2026"
  ))
  if (!is.null(x$bbox)) {
    cli::cli_bullets(c(
      "*" = "bbox (local units): [{format(x$bbox[1])}, {format(x$bbox[2])}] \u2013 [{format(x$bbox[3])}, {format(x$bbox[4])}]"
    ))
  }
  if (nrow(x$converted) > 0) {
    cli::cli_h2("Converted")
    print(x$converted, ...)
  }
  if (nrow(x$skipped) > 0) {
    cli::cli_h2("Skipped")
    print(x$skipped, ...)
  }
  if (nrow(x$failed) > 0) {
    cli::cli_h2("Failed")
    print(x$failed, ...)
  }
  if (length(x$warnings) > 0) {
    cli::cli_h2("Warnings")
    cli::cli_bullets(rlang::set_names(x$warnings, "!"))
  }
  invisible(x)
}
