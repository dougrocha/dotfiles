#!/usr/bin/env bash
# apply-current-image.sh
# Applies whatever default/systemd/kraken/images/current points to, or turns
# the LCD backlight off when set-lighting saved "off". It does no saving or
# pruning; set-kraken-image does that.
#
# The "on" brightness comes from ~/.local/state/lighting/lcd-brightness
# (0-100) when that file exists, else 50.

set -euo pipefail

images_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/images" && pwd)"
current="$images_dir/current"
default_brightness=50  # the cooler's own level before set-lighting existed

# kraken-lcd.service runs this as root, so read the state from the home of
# the user who owns the dotfiles, not from $HOME.
owner_home="$(getent passwd "$(stat -c %U "$images_dir")" | cut -d: -f6)" || owner_home=""
if [[ -z "$owner_home" ]]; then
    echo "Error: can't find the home of the dotfiles owner" >&2
    exit 1
fi
state_dir="$owner_home/.local/state/lighting"

# Share set-lighting's lock so boot and set-kraken-image can't race a switch.
# set-lighting already holds it when it calls this script. Open the lock
# read-only, so running as root never creates a root-owned lock the user
# can't open; if it doesn't exist yet, set-lighting has never run.
if [[ -z "${LIGHTING_LOCKED:-}" && -e "$state_dir/lock" ]]; then
    exec 9<"$state_dir/lock"
    flock 9
fi

state="$(cat "$state_dir/current" 2>/dev/null || echo on)"
brightness="$(cat "$state_dir/lcd-brightness" 2>/dev/null || echo "$default_brightness")"

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
