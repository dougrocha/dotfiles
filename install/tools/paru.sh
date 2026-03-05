#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../env.sh"

PARU_DIR="$BUILD_DIR/paru"

mkdir -p "$BUILD_DIR"

sudo pacman -S --noconfirm --needed base-devel rustup git

if [[ -d "$PARU_DIR" ]]; then
    cd "$PARU_DIR"
    git pull
else
    cd "$BUILD_DIR"
    git clone https://aur.archlinux.org/paru.git
    cd "$PARU_DIR"
fi

makepkg -si --noconfirm

echo "Paru installation complete!"
