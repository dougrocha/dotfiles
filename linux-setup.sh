#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

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
