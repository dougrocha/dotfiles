#!/bin/bash

set -euo pipefail

APP_DIR="$DOTFILES_DIR/default/applications"

echo "Installing applications and web app shortcuts..."

mkdir -p "$HOME/.local/share/applications"

echo "  • Installing desktop entries..."
cp "$APP_DIR"/*.desktop "$HOME/.local/share/applications/" 2>/dev/null || true
cp "$APP_DIR/hidden"/*.desktop "$HOME/.local/share/applications/" 2>/dev/null || true

update-desktop-database ~/.local/share/applications/

echo "  • Installing web app shortcuts..."
"$HOME/.local/bin/install-webapp" "X" "https://x.com" "https://abs.twimg.com/favicons/twitter.3.ico"
"$HOME/.local/bin/install-webapp" "Discord" "https://discord.com/app" "https://discord.com/assets/f9bb9c4af2b9c32a2c5ee0014661546d.png"

echo "✓ Applications and web app shortcuts installed"
