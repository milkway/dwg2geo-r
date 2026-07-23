#!/usr/bin/env bash
# Produce src/rust/vendor.tar.xz + vendor-config.toml for offline CRAN builds.
# Run before building the CRAN submission tarball.
set -euo pipefail
cd "$(dirname "$0")/../src/rust"
cargo vendor vendor > vendor-config.toml
# cargo vendor writes absolute-ish config; normalize the directory reference.
sed -i 's|^directory = ".*"|directory = "rust/vendor"|' vendor-config.toml
tar cJf vendor.tar.xz vendor vendor-config.toml
rm -rf vendor
echo "wrote src/rust/vendor.tar.xz ($(du -h vendor.tar.xz | cut -f1))"
