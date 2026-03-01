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

# Install Paru

sudo pacman -S --noconfirm --needed base-devel rustup git

PARU_DIR="$BUILD_DIR/paru"
[[ -d "$PARU_DIR" ]] && rm -rf "$PARU_DIR"

cd "$BUILD_DIR"
git clone https://aur.archlinux.org/paru.git

cd "$PARU_DIR"
makepkg -si --noconfirm

cd "$HOME"

# Main Applications

paru -S --noconfirm --needed man-db man-pages
paru -S --noconfirm --needed hyprland hypridle hyprlock hyprshot hyprpaper hyprpicker hyprpolkitagent hyprshutdown hyprsunset uwsm xdg-desktop-portal-hyprland sddm ddcutil hyprland-preview-share-picker-git hyprland-guiutils
paru -S --noconfirm --needed quickshell walker mako playerctl cliphist elephant elephant-desktopapplications elephant-providerlist elephant-clipboard elephant-websearch elephant-symbols
paru -S --noconfirm --needed nautilus
paru -S --noconfirm --needed ghostty fish starship tmux opencode
paru -S --noconfirm --needed bat btop chafa fd fzf ripgrep zoxide fastfetch lazygit dust ffmpeg tlrc imagemagick
paru -S --noconfirm --needed chromium imv mpv glow gum
paru -S --noconfirm --needed bluetui wiremix
paru -S --noconfirm --needed xmlstarlet ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji
paru -S --noconfirm --needed yaru-icon-theme
paru -S --noconfirm --needed gpu-screen-recorder

cargo install matugen

# Neovim

sudo pacman -S --noconfirm --needed base-devel cmake ninja curl git

NEOVIM_DIR="$BUILD_DIR/neovim"
[[ -d "$NEOVIM_DIR" ]] && rm -rf "$NEOVIM_DIR"

cd "$BUILD_DIR"
git clone https://github.com/neovim/neovim.git

cd "$NEOVIM_DIR"
make CMAKE_BUILD_RELEASE=Release
sudo make install

cd "$HOME"

# SDDM Setup
sudo systemctl enable sddm
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/autologin.conf > /dev/null << EOF
[Autologin]
User=$USER
Session=hyprland-uwsm
EOF

# Hyprland
systemctl --user enable --now hyprpaper.service
systemctl --user enable --now hyprpolkitagent.service
systemctl --user enable --now hypridle.service
systemctl --user enable --now hyprsunset.service

# Walker
systemctl --user enable --now elephant.service

# Screen Recorder
systemctl --user enable --now gpu-screen-recorder.service
