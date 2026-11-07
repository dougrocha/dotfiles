#!/bin/bash

set -euo pipefail

# shellcheck source=SCRIPTDIR/../lib.sh
source "$DOTFILES_DIR/install/lib.sh"
# shellcheck source=SCRIPTDIR/../../default/lighting/lighting.sh
source "$DOTFILES_DIR/default/lighting/lighting.sh"
# shellcheck source=SCRIPTDIR/../../default/systemd/openrgb/profiles.sh
source "$DOTFILES_DIR/default/systemd/openrgb/profiles.sh"

SERVICE_FILE="$DOTFILES_DIR/default/systemd/openrgb/openrgb-profile.service"
OPENRGB_BIN="$lighting_openrgb_bin"
PROFILES_DIR="$HOME/.config/OpenRGB/profiles"

echo "OpenRGB Profile Autostart Setup"
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""

if [[ ! -x "$OPENRGB_BIN" ]]; then
    echo "✗ Error: patched OpenRGB binary not found/executable at $OPENRGB_BIN"
    echo "  Build it first (see Lian Li Uni Hub SL color fix)."
    exit 1
fi

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
sed "s|@DOTFILES_DIR@|$DOTFILES_DIR|g" "$SERVICE_FILE" >"$HOME/.config/systemd/user/openrgb-profile.service"

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
