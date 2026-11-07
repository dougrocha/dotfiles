#!/bin/bash

set -euo pipefail

SERVICE_FILE="$DOTFILES_DIR/default/systemd/openrgb/openrgb-profile.service"
OPENRGB_BIN="$BUILD_DIR/openrgb-src/openrgb"
PROFILES_DIR="$HOME/.config/OpenRGB/profiles"
# shellcheck source=SCRIPTDIR/../../default/systemd/openrgb/profiles.sh
source "$DOTFILES_DIR/default/systemd/openrgb/profiles.sh"

echo "OpenRGB Profile Autostart Setup"
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""

if [[ ! -x "$OPENRGB_BIN" ]]; then
    echo "✗ Error: patched OpenRGB binary not found/executable at $OPENRGB_BIN"
    echo "  Build it first (see Lian Li Uni Hub SL color fix)."
    exit 1
fi

# set-lighting on/off loads these two profiles.
for profile in "$profile_on" "$profile_off"; do
    if [[ ! -f "$PROFILES_DIR/$profile.json" ]]; then
        echo "✗ Error: profile not found at $PROFILES_DIR/$profile.json"
        exit 1
    fi
done

if [[ ! -f "$SERVICE_FILE" ]]; then
    echo "✗ Error: Service file not found at $SERVICE_FILE"
    exit 1
fi

echo "Binary:  $OPENRGB_BIN"
echo "Profiles: $PROFILES_DIR/{$profile_on,$profile_off}.json"
echo ""
echo "Deploying user service..."

mkdir -p "$HOME/.config/systemd/user"
cp "$SERVICE_FILE" "$HOME/.config/systemd/user/openrgb-profile.service"

systemctl --user daemon-reload
systemctl --user enable openrgb-profile.service
# Restart, since enable --now leaves an already active oneshot on the old ExecStart.
if ! systemctl --user restart openrgb-profile.service; then
    echo "✗ Error: the service is enabled, but applying the profile failed just now."
    echo "  It will retry at the next login. See: journalctl --user -u openrgb-profile"
    exit 1
fi

echo "✓ OpenRGB profile service deployed successfully!"
echo ""
echo "Service Details:"
echo "───────────────────────────────────────────────────────────────────────────"
echo "  Status:   systemctl --user status openrgb-profile"
echo "  Logs:     journalctl --user -u openrgb-profile"
echo "  Disable:  systemctl --user disable --now openrgb-profile"
echo ""
echo "Switch lighting: set-lighting on|off (remembered across boots)"

# vim: ft=sh
