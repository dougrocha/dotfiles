#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/profiles.sh
source "$script_dir/profiles.sh"
# shellcheck source=SCRIPTDIR/../../lighting/lighting.sh
source "$script_dir/../../lighting/lighting.sh"

lighting_lock

state="$(cat "$lighting_state_file" 2>/dev/null || echo on)"

case "$state" in
    on)  profile="$profile_on" ;;
    off) profile="$profile_off" ;;
    *)
        echo "Error: unknown lighting state '$state' in $lighting_state_file" >&2
        exit 1
        ;;
esac

# OpenRGB exits 0 even when the profile fails to load, so check its output.
# --noautoconnect drives the devices directly, which assumes no OpenRGB server
# (openrgb --server or the GUI) is running and holding them.
output="$("$lighting_openrgb_bin" --noautoconnect --profile "$profile" 2>&1)" || true
printf '%s\n' "$output"
if [[ "$output" != *"Profile loaded successfully"* ]]; then
    echo "Error: OpenRGB could not load profile '$profile'" >&2
    exit 1
fi
