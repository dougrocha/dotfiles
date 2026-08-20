#!/usr/bin/env bash
# apply-current-image.sh
# Boot-time only: applies whatever default/systemd/kraken/images/current
# points to. No saving, no pruning — that's set-kraken-image's job.

set -euo pipefail

images_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/images" && pwd)"
current="$images_dir/current"

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

liquidctl --match kraken initialize all
liquidctl --match kraken set lcd screen "$mode" "$target"
