#!/bin/bash
# Rust via rustup. Arch's rustup package ships no toolchain.

set -euo pipefail

export PATH="$HOME/.cargo/bin:$PATH"

# --no-modify-path: the shell config is ours.
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

# vim: ft=sh
