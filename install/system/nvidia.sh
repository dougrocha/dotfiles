#!/bin/bash

set -euo pipefail

# Enable multilib repository in pacman.conf
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "Enabling multilib repository..."
    sudo tee -a /etc/pacman.conf > /dev/null << 'EOF'

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
    sudo pacman -Sy
fi

paru -S --noconfirm --needed \
    linux-headers \
    nvidia-open-dkms \
    nvidia-utils \
    lib32-nvidia-utils \
    nvidia-settings \
    libva-nvidia-driver \
    dkms
