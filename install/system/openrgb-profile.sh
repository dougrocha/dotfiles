#!/bin/bash

set -euo pipefail

SERVICE_FILE="$DOTFILES_DIR/default/systemd/openrgb/openrgb-profile.service"
OPENRGB_BIN="$BUILD_DIR/openrgb-src/openrgb"
PROFILE="$HOME/.config/OpenRGB/profiles/MutedBlue.json"

echo "OpenRGB Profile Autostart Setup"
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""

if [[ ! -x "$OPENRGB_BIN" ]]; then
    echo "✗ Error: patched OpenRGB binary not found/executable at $OPENRGB_BIN"
    echo "  Build it first (see Lian Li Uni Hub SL color fix)."
    exit 1
fi

if [[ ! -f "$PROFILE" ]]; then
    echo "✗ Error: profile not found at $PROFILE"
    exit 1
fi

if [[ ! -f "$SERVICE_FILE" ]]; then
    echo "✗ Error: Service file not found at $SERVICE_FILE"
    exit 1
fi

echo "Binary:  $OPENRGB_BIN"
echo "Profile: $PROFILE"
echo ""
echo "Deploying user service..."

mkdir -p "$HOME/.config/systemd/user"
cp "$SERVICE_FILE" "$HOME/.config/systemd/user/openrgb-profile.service"

systemctl --user daemon-reload
systemctl --user enable --now openrgb-profile.service

echo "✓ OpenRGB profile service deployed successfully!"
echo ""
echo "Service Details:"
echo "───────────────────────────────────────────────────────────────────────────"
echo "  Status:   systemctl --user status openrgb-profile"
echo "  Logs:     journalctl --user -u openrgb-profile"
echo "  Disable:  systemctl --user disable --now openrgb-profile"

# vim: ft=sh
