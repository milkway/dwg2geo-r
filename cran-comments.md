## Resubmission

This is a resubmission of a new package. In this version I have:

* Excluded `cran-comments.md` from the source tarball via `.Rbuildignore`
  (fixes the "Non-standard file/directory found at top level" NOTE).
* Replaced the relative `LICENSE.md` link in `README.md` with an absolute
  URL (fixes the "invalid file URI" NOTE).
* Replaced the `https://crates.io/crates/acadrust` link in `README.md`
  with `https://docs.rs/acadrust`. The crate exists, but crates.io serves
  its pages via JavaScript and returns 404 to non-browser clients, so the
  docs.rs page is linked instead.
* Quoted 'DWG' and 'GeoJSON' in the Title. The remaining flagged word,
  "Auditable", is a correctly spelled English word.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

* The "checking compiled code ... Found 'abort'" warning comes from the Rust
  standard library's panic runtime, which every Rust static library links.
  No package code path calls abort(): all conversion errors are returned as
  values across the FFI boundary and surfaced as R conditions.

## Tarball size

The source tarball is ~9.5 MB because all Rust crate dependencies are
vendored (src/rust/vendor.tar.xz), as the CRAN policy for offline Rust
builds requires; most of that is the platform API binding crates
(windows-sys, linux-raw-sys, libc) needed to compile on CRAN's own
builders.

## Rust

The package compiles a Rust static library (SystemRequirements: Cargo,
rustc >= 1.85), following the CRAN "Using Rust" policy: all crate
dependencies are vendored in src/rust/vendor.tar.xz, the build runs
offline with at most 2 jobs, and cargo/rustc versions are reported at
build time.
