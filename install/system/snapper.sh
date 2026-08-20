#!/bin/bash

set -euo pipefail

echo "Configuring snapper retention limits..."

for cfg in home root; do
    if snapper -c "$cfg" get-config &> /dev/null; then
        sudo snapper -c "$cfg" set-config \
            "TIMELINE_LIMIT_HOURLY=5" \
            "TIMELINE_LIMIT_DAILY=3" \
            "TIMELINE_LIMIT_MONTHLY=0" \
            "TIMELINE_LIMIT_YEARLY=0" \
            "NUMBER_LIMIT=10" \
            "NUMBER_LIMIT_IMPORTANT=5"
    fi
done

sudo systemctl enable --now snapper-cleanup.timer snapper-timeline.timer

echo "✓ Snapper retention configured"
