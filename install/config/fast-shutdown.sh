#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../env.sh"

sudo mkdir -p /etc/systemd/system.conf.d
sudo cp "$DOTFILES_DIR/default/systemd/faster-shutdown.conf" /etc/systemd/system.conf.d/10-faster-shutdown.conf

sudo mkdir -p /etc/systemd/system/user@.service.d
sudo cp "$DOTFILES_DIR/default/systemd/user@.service.d/faster-shutdown.conf" /etc/systemd/system/user@.service.d/faster-shutdown.conf

sudo systemctl daemon-reload
