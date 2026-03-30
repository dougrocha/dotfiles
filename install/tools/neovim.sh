#!/bin/bash

set -euo pipefail

source "$(dirname "$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")")/env.sh"

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [[ -d "$TPM_DIR" ]]; then
    cd "$TPM_DIR"
    git pull
else
    mkdir -p "$HOME/.tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

NEOVIM_DIR="$BUILD_DIR/neovim"

mkdir -p "$BUILD_DIR"

sudo pacman -S --noconfirm --needed base-devel cmake ninja curl git

if [[ -d "$NEOVIM_DIR" ]]; then
    cd "$NEOVIM_DIR"
    git fetch origin
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
