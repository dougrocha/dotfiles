#!/bin/bash

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "$DOTFILES_DIR/install/lib.sh"

# TPM keeps plugins next to tmux.conf, which ./link puts in ~/.config/tmux.
PLUGINS_DIR="$HOME/.config/tmux/plugins"
TPM_DIR="$PLUGINS_DIR/tpm"

mkdir -p "$PLUGINS_DIR"
sync_repo "$TPM_DIR" https://github.com/tmux-plugins/tpm master

"$TPM_DIR/bin/install_plugins"
"$TPM_DIR/bin/update_plugins" all

# vim: ft=sh
