#!/bin/bash

set -euo pipefail

export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BUILD_DIR="${BUILD_DIR:-$HOME/builds}"

# Write env to ~/.config/env so the interactive shell picks it up
mkdir -p "$HOME/.config"
cat > "$HOME/.config/env" <<EOF
export DOTFILES_DIR="$DOTFILES_DIR"
export BUILD_DIR="$BUILD_DIR"
EOF

ansi_art='
 ______   _______           _______
(  __  \ (  ___  )|\     /|(  ____ \
| (  \  )| (   ) || )   ( || (    \/
| |   ) || |   | || |   | || |
| |   | || |   | || |   | || | ____
| |   ) || |   | || |   | || | \_  )
| (__/  )| (___) || (___) || (___) |
(______/ (_______)(_______)(_______)
                                    '
clear
echo -e "\n$ansi_art\n"

mkdir -p "$BUILD_DIR"

"$DOTFILES_DIR/stow"

"$DOTFILES_DIR/install/base.sh"

systemctl --user enable --now hyprpaper.service
systemctl --user enable --now hyprpolkitagent.service
systemctl --user enable --now hypridle.service
systemctl --user enable --now hyprsunset.service

echo -e "Setup complete! Please reboot to start Hyprland."
