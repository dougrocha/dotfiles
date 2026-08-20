#!/bin/bash

set -euo pipefail

SERVICE_FILE="$DOTFILES_DIR/default/systemd/kraken/kraken-lcd.service"
APPLY_SCRIPT="$DOTFILES_DIR/default/systemd/kraken/apply-current-image.sh"
CURRENT_IMAGE="$DOTFILES_DIR/default/systemd/kraken/images/current"

echo "NZXT Kraken LCD Image Setup"
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""

if ! command -v liquidctl &> /dev/null; then
    echo "✗ Error: liquidctl not found. Install it first (pacman -S liquidctl)."
    exit 1
fi

if [[ ! -f "$SERVICE_FILE" ]]; then
    echo "✗ Error: Service file not found at $SERVICE_FILE"
    exit 1
fi

if [[ ! -L "$CURRENT_IMAGE" ]]; then
    echo "✗ Error: No current image set at $CURRENT_IMAGE"
    echo "  Run 'set-kraken-image <image-path>' first."
    exit 1
fi

chmod +x "$APPLY_SCRIPT"

echo "Current image: $(readlink -f "$CURRENT_IMAGE")"
echo ""
echo "Deploying service..."

sudo cp "$SERVICE_FILE" /etc/systemd/system/kraken-lcd.service
sudo systemctl daemon-reload
sudo systemctl enable --now kraken-lcd.service

echo "✓ Kraken LCD service deployed successfully!"
echo ""
echo "Service Details:"
echo "───────────────────────────────────────────────────────────────────────────"
echo "  Status:   systemctl status kraken-lcd"
echo "  Logs:     journalctl -u kraken-lcd"
echo "  Disable:  sudo systemctl disable --now kraken-lcd"
echo ""
echo "To change the image later: set-kraken-image <new-image-path>"
echo "(takes effect immediately; also becomes the boot-time image)"

# vim: ft=sh
