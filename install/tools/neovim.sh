#!/bin/bash

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "$DOTFILES_DIR/install/lib.sh"

NEOVIM_DIR="$BUILD_DIR/neovim"

mkdir -p "$BUILD_DIR"

updating=0
[[ -d "$NEOVIM_DIR/.git" ]] && updating=1

sync_repo "$NEOVIM_DIR" https://github.com/neovim/neovim.git master
cd "$NEOVIM_DIR"

commit=$(git rev-parse HEAD)

if needs_build neovim "$commit" "$NEOVIM_DIR/build/bin/nvim" /usr/local/bin/nvim; then
    if ((updating)); then
        make distclean
    fi

    make CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make install
    mark_built neovim "$commit"
else
    info "neovim already built at ${commit:0:8}"
fi

if command -v cargo >/dev/null 2>&1; then
    cargo install tree-sitter-cli
else
    echo "  ! cargo not found, skipping tree-sitter-cli" >&2
fi
