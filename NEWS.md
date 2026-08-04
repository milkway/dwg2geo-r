# dwg2geo 0.2.4

* Fixed installation on CRAN's macOS builders: `cargo` is invoked with
  `~/.cargo/bin` appended to the `PATH`, covering rustup installations that
  are not on the default `PATH` (0.2.3 failed to install on all four CRAN
  macOS flavors with "cargo: command not found").
* Upgraded the embedded conversion core to dwg2geo 0.2.3, which adds six
  entity semantics (curve-fit polylines, dimensions, mlines, multileaders,
  polyface meshes, model-space attdefs) and geodata reporting.

# dwg2geo 0.2.3

* CRAN resubmission: the Rust build tree (`src/rust/target` and the extracted
  `src/rust/vendor` sources) is now removed as soon as the shared library is
  linked. R (>= 4.5) scans leftover objects under `src/` for entry points such
  as `abort()`, and the Rust standard library's panic runtime in the
  intermediate static library triggered a spurious "Found 'abort'" WARNING.
  No R-facing changes.

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
