#!/usr/bin/env bash
# Auto-initialize new tmux sessions with named windows
# Called by after-new-session hook in ~/.config/tmux/hooks.conf

SESSION_NAME="$1"
SESSION_PATH="$2"

WINDOW_1_NAME="nvim"
WINDOW_2_NAME="scratch"
DEFAULT_WINDOW=1

tmux rename-window -t "${SESSION_NAME}:1" "$WINDOW_1_NAME"

tmux new-window -dt "${SESSION_NAME}:2" -n "$WINDOW_2_NAME" -c "$SESSION_PATH"

tmux select-window -t "${SESSION_NAME}:${DEFAULT_WINDOW}"
