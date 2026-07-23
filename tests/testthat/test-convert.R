test_that("dwg_convert validates its arguments", {
  expect_error(dwg_convert(42), "single file path")
  expect_error(dwg_convert("no/such/file.dwg"), "does not exist")
  expect_error(dwg_convert(tempdir()), "directory")

  junk <- withr::local_tempfile(fileext = ".dwg")
  writeBin(as.raw(1:64), junk)
  expect_error(dwg_convert(junk, polygonize_closed = NA), "TRUE.*FALSE")
  expect_error(dwg_convert(junk, curve_tolerance = -1), "positive number")
  expect_error(dwg_convert(junk, curve_tolerance = "x"), "positive number")
})

test_that("garbage bytes fail with a classed error, not a crash", {
  junk <- withr::local_tempfile(fileext = ".dwg")
  writeBin(as.raw(rep(1:255, 10)), junk)
  expect_error(
    dwg_convert(junk, quiet = TRUE),
    class = "dwg2geo_convert_error"
  )
})

test_that("dwg_core_version reports a semver string", {
  expect_match(dwg_core_version(), "^\\d+\\.\\d+\\.\\d+$")
})

test_that("dwg_as_sf rejects non-results", {
  expect_error(dwg_as_sf(list()), "dwg2geo_result")
})

# Full conversion is exercised when a real drawing is supplied via an
# environment variable (developer machines / CI with fixtures); CRAN runs
# only the offline checks above.
test_that("a real drawing converts end to end", {
  sample <- Sys.getenv("DWG2GEO_TEST_DWG")
  skip_if(!nzchar(sample) || !file.exists(sample), "no test drawing supplied")

  result <- dwg_convert(sample, quiet = TRUE)
  expect_s3_class(result, "dwg2geo_result")
  expect_gt(result$feature_count, 0)
  expect_s3_class(result$converted, "tbl_df")
  expect_match(result$source_sha256, "^[0-9a-f]{64}$")
  fc <- jsonlite::fromJSON(result$geojson, simplifyVector = FALSE)
  expect_identical(fc$type, "FeatureCollection")
  expect_length(fc$features, result$feature_count)

  # determinism: converting the same bytes twice is byte-identical
  again <- dwg_convert(sample, quiet = TRUE)
  expect_identical(result$geojson, again$geojson)
})
