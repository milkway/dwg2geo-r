# dwg2geo 0.2.2

* CRAN resubmission: excluded `cran-comments.md` from the source tarball,
  fixed the license and acadrust links in `README.md`, and quoted the
  format names in the `DESCRIPTION` title. No code changes.

# dwg2geo 0.2.1

* Initial CRAN submission.
* `dwg_convert()` converts AutoCAD 2013+ DWG drawings to GeoJSON in-process
  (pure-Rust core, no CAD software required), returning the feature
  collection plus a full audit report (converted/skipped/failed tibbles with
  reasons, warnings, bbox, source SHA-256).
* `dwg_as_sf()` reads a result into sf, keeping the CRS decision explicit.
* `dwg_core_version()` reports the embedded conversion core version.
