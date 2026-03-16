#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../env.sh"

set-font 'JetBrainsMono Nerd Font' 'monospace'

"$DOTFILES_DIR/install/tools/paru.sh"

mapfile -t packages < <(grep -v '^#' "$DOTFILES_DIR/install/packages" | grep -v '^$' | sed 's/[[:space:]]*#.*$//' | awk 'NF')
paru -S --noconfirm --needed "${packages[@]}"

# "$DOTFILES_DIR/install/tools/neovim.sh"
"$DOTFILES_DIR/install/system/sddm.sh"
"$DOTFILES_DIR/install/config/fast-shutdown.sh"

if lspci | grep -i nvidia &> /dev/null; then
    "$DOTFILES_DIR/install/system/nvidia.sh"
fi

"$DOTFILES_DIR/install/setup/defaults.sh"
"$DOTFILES_DIR/install/setup/setup-applications.sh"

cargo install matugen
