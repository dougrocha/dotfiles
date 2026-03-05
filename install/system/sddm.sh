#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../env.sh"

SDDM_CONF_TEMPLATE="$DOTFILES_DIR/default/sddm/autologin.conf"

echo "Configuring SDDM display manager..."

sudo mkdir -p /etc/sddm.conf.d

envsubst < "$SDDM_CONF_TEMPLATE" | sudo tee /etc/sddm.conf.d/autologin.conf > /dev/null

sudo systemctl enable sddm

echo "✓ SDDM configured for user: $USER"
