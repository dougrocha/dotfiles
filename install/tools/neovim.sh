#!/bin/bash

set -euo pipefail

NEOVIM_DIR="$BUILD_DIR/neovim"

mkdir -p "$BUILD_DIR"

if [[ -d "$NEOVIM_DIR" ]]; then
    cd "$NEOVIM_DIR"
    git fetch origin master
    git switch master
    git reset --hard origin/master
else
    cd "$BUILD_DIR"
    git clone https://github.com/neovim/neovim.git
    cd "$NEOVIM_DIR"
    git switch master
fi

sudo make CMAKE_BUILD_TYPE=RelWithDebInfo install

cargo install tree-sitter-cli
