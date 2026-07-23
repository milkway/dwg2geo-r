## Resubmission

This is a resubmission of a new package (0.2.3). The 0.2.2 pre-test
reported, on Debian, a WARNING in "checking compiled code":

    Found 'abort', possibly from 'abort' (C)
      Object: 'rust/target/release/libdwg2geo_r.a'

The symbol came from the Rust standard library's panic runtime inside the
*intermediate* static library that the build left behind under
`src/rust/target` (no package code path calls abort(); the final shared
object does not reference it, all conversion errors cross the FFI boundary
as values and become R conditions). In this version:

* `src/Makevars` and `src/Makevars.win` now delete `rust/target` and the
  extracted `rust/vendor` sources as soon as the shared library is linked,
  so no Rust intermediate objects remain for the compiled-code check to
  scan. This is the same fix adopted by the rextendr/hellorust templates
  for this check.

The remaining "possibly misspelled" word in the DESCRIPTION, "Auditable",
is a correctly spelled English word (the package's key feature is an audit
report of every converted, skipped, and failed entity).

## R CMD check results

0 errors | 0 warnings | 1 note (R CMD check --as-cran, R 4.6.0; the
"checking compiled code" step now passes cleanly)

* This is a new submission.

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
