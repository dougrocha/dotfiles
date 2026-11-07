#!/usr/bin/env bash
# apply-profile.sh
# Loads the OpenRGB profile for the lighting state that set-lighting saved.
# Runs at login from openrgb-profile.service and from set-lighting.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/profiles.sh
source "$script_dir/profiles.sh"

state_dir="$HOME/.local/state/lighting"
state_file="$state_dir/current"
openrgb="${BUILD_DIR:-$HOME/builds}/openrgb-src/openrgb"

# Share set-lighting's lock so the login service can't race a manual switch.
# set-lighting already holds it when it calls this script.
if [[ -z "${LIGHTING_LOCKED:-}" ]]; then
    mkdir -p "$state_dir"
    exec 9>"$state_dir/lock"
    flock 9
fi

state="$(cat "$state_file" 2>/dev/null || echo on)"

case "$state" in
    on)  profile="$profile_on" ;;
    off) profile="$profile_off" ;;
    *)
        echo "Error: unknown lighting state '$state' in $state_file" >&2
        exit 1
        ;;
esac

# OpenRGB exits 0 even when the profile fails to load, so check its output.
# --noautoconnect drives the devices directly, which assumes no OpenRGB server
# (openrgb --server or the GUI) is running and holding them.
output="$("$openrgb" --noautoconnect --profile "$profile" 2>&1)" || true
printf '%s\n' "$output"
if [[ "$output" != *"Profile loaded successfully"* ]]; then
    echo "Error: OpenRGB could not load profile '$profile'" >&2
    exit 1
fi
