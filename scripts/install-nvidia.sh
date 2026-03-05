#!/bin/bash

set -euo pipefail

echo "Installing NVIDIA drivers and utilities..."

# Enable multilib repository in pacman.conf
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "Enabling multilib repository..."
    sudo tee -a /etc/pacman.conf > /dev/null << 'EOF'

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
    sudo pacman -Sy
fi

# Install NVIDIA packages
paru -S --noconfirm --needed \
    linux-headers \
    nvidia-open-dkms \
    nvidia-utils \
    lib32-nvidia-utils \
    nvidia-settings \
    libva-nvidia-driver \
    dkms

echo "NVIDIA installation complete!"
echo ""
echo "Note: If you experience audio pops:"
echo "  1. Query supported clocks: nvidia-smi --query-supported-clocks=memory --format=csv"
echo "  2. Set lock: nvidia-smi -i 0 -lgc <min_freq>,<max_freq>"
