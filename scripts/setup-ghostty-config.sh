#!/bin/bash

set -euo pipefail

CONFIG_DIR="$HOME/.config/ghostty"

OS="$(uname -s)"

case "$OS" in
    Darwin)
        cat > "$CONFIG_DIR/config-macos" << 'EOF'
font-family = "Monaspace Neon"
font-size = 13

macos-option-as-alt = true
macos-window-buttons = hidden
macos-titlebar-style = hidden
macos-window-shadow = false

mouse-hide-while-typing = true

# vim: set ft=conf:
EOF
        ;;
    Linux)
        cat > "$CONFIG_DIR/config-linux" << 'EOF'
font-family = "JetBrainsMono Nerd Font"

keybind = shift+insert=paste_from_clipboard
keybind = control+insert=copy_to_clipboard

# vim: set ft=conf:
EOF
        ;;
    *)
        echo "NUH UH! You can't do that on '$OS' - Ghostty config generation says NO!"
        exit 1
        ;;
esac

echo "Done configuring Ghostty!"
