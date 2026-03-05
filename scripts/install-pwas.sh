#!/bin/bash

set -euo pipefail

PWAS=(
    "X|https://x.com|https://abs.twimg.com/favicons/twitter.3.ico"
    "Discord|https://discord.com/app|https://discord.com/assets/f9bb9c4af2b9c32a2c5ee0014661546d.png"
)

for pwa in "${PWAS[@]}"; do
    IFS='|' read -r name url icon <<< "$pwa"
    if [[ -n "$icon" ]]; then
        "$HOME/.local/bin/install-webapp" "$name" "$url" "$icon"
    else
        "$HOME/.local/bin/install-webapp" "$name" "$url"
    fi
done
