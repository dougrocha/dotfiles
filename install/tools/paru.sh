#!/bin/bash

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "$DOTFILES_DIR/install/lib.sh"

if ! is_linux; then
    warn "Paru requires Arch Linux"
    exit 1
fi

if command -v paru >/dev/null 2>&1; then
    if [[ ${FORCE:-0} == 1 ]]; then
        paru -S --noconfirm --rebuild=yes paru
    else
        paru -S --noconfirm --needed paru
    fi
    exit 0
fi

PARU_DIR="$BUILD_DIR/paru"

mkdir -p "$BUILD_DIR"

sudo pacman -S --noconfirm --needed base-devel git

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
