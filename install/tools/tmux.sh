#!/bin/bash

set -euo pipefail

# TPM keeps plugins next to tmux.conf, which ./link puts in ~/.config/tmux.
PLUGINS_DIR="$HOME/.config/tmux/plugins"
TPM_DIR="$PLUGINS_DIR/tpm"

if [[ ! -d "$TPM_DIR" ]]; then
    mkdir -p "$PLUGINS_DIR"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

"$TPM_DIR/bin/install_plugins"
"$TPM_DIR/bin/update_plugins" all

# vim: ft=sh
