#!/bin/bash

set -euo pipefail

# List of desktop files to hide (without .desktop extension)
APPS_TO_HIDE=(
    "avahi-discover"
    "bssh"
    "bvnc"
    "btop"
    "cmake-gui"
    "java-java-openjdk"
    "qv4l2"
    "qvidcap"
)

# Show usage
if [[ "${1:-}" == "--list" ]]; then
    echo "Available desktop applications:"
    ls /usr/share/applications/*.desktop 2>/dev/null | xargs -n1 basename | sed 's/.desktop$//' | sort
    exit 0
fi

mkdir -p "$HOME/.local/share/applications"

for app in "${APPS_TO_HIDE[@]}"; do
    cat > "$HOME/.local/share/applications/${app}.desktop" << EOF
[Desktop Entry]
NoDisplay=true
EOF
done

echo "Hidden ${#APPS_TO_HIDE[@]} desktop applications"
