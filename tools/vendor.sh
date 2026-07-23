#!/usr/bin/env bash
# Produce src/rust/vendor.tar.xz + vendor-config.toml for offline CRAN builds.
# Run before building the CRAN submission tarball. Uses cargo-vendor-filterer
# (platform-filtered, smaller archive) when installed, plain cargo vendor
# otherwise.
set -euo pipefail
cd "$(dirname "$0")/../src/rust"
rm -rf vendor .cargo

if command -v cargo-vendor-filterer >/dev/null 2>&1; then
  cargo vendor-filterer \
    --platform=x86_64-unknown-linux-gnu \
    --platform=aarch64-unknown-linux-gnu \
    --platform=x86_64-pc-windows-gnu \
    --platform=x86_64-apple-darwin \
    --platform=aarch64-apple-darwin \
    vendor > vendor-config.toml
else
  cargo vendor vendor > vendor-config.toml
fi
# Paths in cargo config resolve relative to the parent of the .cargo dir the
# config lives in (src/); Makevars installs this file at $CARGO_HOME/config.toml.
sed -i 's|^directory = ".*"|directory = "rust/vendor"|' vendor-config.toml
tar cJf vendor.tar.xz vendor vendor-config.toml
rm -rf vendor
echo "wrote src/rust/vendor.tar.xz ($(du -h vendor.tar.xz | cut -f1))"
