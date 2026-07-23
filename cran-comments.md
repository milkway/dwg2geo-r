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
