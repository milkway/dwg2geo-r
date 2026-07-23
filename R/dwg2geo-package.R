#' @keywords internal
"_PACKAGE"

#' @useDynLib dwg2geo, .registration = TRUE
## usethis namespace: start
#' @importFrom rlang %||%
## usethis namespace: end
NULL

# Thin wrappers over the extendr-exported symbols. The Rust side returns the
# whole conversion result as one JSON string; shaping happens in dwg_convert().
convert_impl <- function(data, polygonize_closed, curve_tolerance) {
  .Call(wrap__convert_impl, data, polygonize_closed, curve_tolerance)
}

core_version_impl <- function() {
  .Call(wrap__core_version_impl)
}
