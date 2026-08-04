## Update fixing CRAN check ERRORs

This release fixes the installation ERRORs reported for 0.2.3 on all four
CRAN macOS flavors (r-release/r-oldrel, arm64/x86_64):

    /bin/sh: cargo: command not found
    make: *** [rust/target/release/libdwg2geo_r.a] Error 127

The CRAN macOS builders install Rust via rustup in `~/.cargo/bin`, which is
not on the default `PATH`. `src/Makevars` and `src/Makevars.win` now append
`$(HOME)/.cargo/bin` to the `PATH` before invoking cargo/rustc, as the
"Using Rust in CRAN packages" document recommends (checking "personal
versions in ~/.cargo/bin (which are often not on the path)").

This release also upgrades the embedded (vendored) Rust conversion core
from dwg2geo 0.2.2 to 0.2.3; no R-facing API changes.

## R CMD check results

0 errors | 0 warnings | 1 note (R CMD check --as-cran, R 4.6.0)

* "Days since last update: 0" — this update only fixes the macOS
  installation ERRORs reported by the CRAN Team (deadline 2026-08-21).

The remaining "possibly misspelled" word in the DESCRIPTION, "Auditable",
is a correctly spelled English word (the package's key feature is an audit
report of every converted, skipped, and failed entity).

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
