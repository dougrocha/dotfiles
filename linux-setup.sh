#!/bin/bash

set -euo pipefail

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

export BUILD_DIR="$HOME/builds"
mkdir -p "$BUILD_DIR"

./scripts/install-paru.sh

mapfile -t packages < <(grep -v '^#' "./install/packages" | grep -v '^$' | sed 's/[[:space:]]*#.*$//' | awk 'NF')
paru -S --noconfirm --needed "${packages[@]}"

cargo install matugen

./scripts/install-neovim.sh

# SDDM Setup
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/autologin.conf > /dev/null << EOF
[Autologin]
User=$USER
Session=hyprland-uwsm
EOF

sudo systemctl enable sddm

# Hyprland
systemctl --user enable --now hyprpaper.service
systemctl --user enable --now hyprpolkitagent.service
systemctl --user enable --now hypridle.service
systemctl --user enable --now hyprsunset.service
