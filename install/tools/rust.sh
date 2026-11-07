#!/bin/bash
# Rust via rustup from the official installer, with the nightly toolchain as default.

set -euo pipefail

export PATH="$HOME/.cargo/bin:$PATH"

if ! command -v rustup >/dev/null 2>&1; then
    echo "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
        sh -s -- -y --no-modify-path --default-toolchain none
fi

rustup default nightly

# default installs a missing toolchain; update refreshes existing ones.
rustup update
rustup component add rust-analyzer

cargo --version

cargo install cargo-edit tree-sitter-cli wasm-pack

# vim: ft=sh
