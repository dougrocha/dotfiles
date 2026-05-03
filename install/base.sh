#!/bin/bash

set -euo pipefail

source "$DOTFILES_DIR/install/platform"

"$DOTFILES_DIR/install/tools/paru.sh"

mapfile -t packages < <(grep -v '^#' "$DOTFILES_DIR/install/packages" | grep -v '^$' | sed 's/[[:space:]]*#.*$//' | awk 'NF')
paru -S --noconfirm --needed "${packages[@]}"

"$DOTFILES_DIR/install/tools/neovim.sh"
"$DOTFILES_DIR/install/system/sddm.sh"

if [ "$PLATFORM_GPU" = "nvidia" ]; then
    "$DOTFILES_DIR/install/system/nvidia.sh"
fi

cargo install matugen
