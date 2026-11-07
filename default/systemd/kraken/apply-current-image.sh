#!/usr/bin/env bash

set -euo pipefail

images_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/images" && pwd)"
current="$images_dir/current"
default_brightness=50  # the cooler's own level before set-lighting existed

# shellcheck source=SCRIPTDIR/../../lighting/lighting.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../lighting/lighting.sh"

lighting_lock

state="$(cat "$lighting_state_file" 2>/dev/null || echo on)"
# lcd-brightness (0-100) in the state dir sets the "on" level.
brightness="$(cat "$lighting_state_dir/lcd-brightness" 2>/dev/null || echo "$default_brightness")"

case "$state" in
    on|off) ;;
    *)
        echo "Error: unknown lighting state '$state'" >&2
        exit 1
        ;;
esac

if [[ ! "$brightness" =~ ^[0-9]+$ ]] || (( 10#$brightness > 100 )); then
    echo "Warning: bad LCD brightness '$brightness', using $default_brightness" >&2
    brightness="$default_brightness"
fi

liquidctl --match kraken initialize all >/dev/null

if [[ "$state" == "off" ]]; then
    liquidctl --match kraken set lcd screen brightness 0
    exit 0
fi

if [[ ! -L "$current" ]]; then
    echo "Error: no current image set ($current is not a symlink)" >&2
    exit 1
fi

target="$(readlink -f "$current")"

if [[ ! -f "$target" ]]; then
    echo "Error: current image target missing: $target" >&2
    exit 1
fi

case "$target" in
    *.gif) mode="gif" ;;
    *)     mode="static" ;;
esac

liquidctl --match kraken set lcd screen brightness "$brightness"
liquidctl --match kraken set lcd screen "$mode" "$target"
