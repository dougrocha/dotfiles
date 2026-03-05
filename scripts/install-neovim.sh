#!/bin/bash

set -euo pipefail

BUILD_DIR="${BUILD_DIR:-$HOME/builds}"
NEOVIM_DIR="$BUILD_DIR/neovim"

mkdir -p "$BUILD_DIR"

sudo pacman -S --noconfirm --needed base-devel cmake ninja curl git

if [[ -d "$NEOVIM_DIR" ]]; then
    cd "$NEOVIM_DIR"
    git pull
else
    cd "$BUILD_DIR"
    git clone https://github.com/neovim/neovim.git
    cd "$NEOVIM_DIR"
fi

make CMAKE_BUILD_RELEASE=Release
sudo make install

echo "Neovim installation complete!"
