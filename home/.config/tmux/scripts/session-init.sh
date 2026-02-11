#!/usr/bin/env bash
# Auto-initialize new tmux sessions with named windows
# Called by after-new-session hook in ~/.config/tmux/hooks.conf

SESSION_NAME="$1"
SESSION_PATH="$2"

WINDOW_1_NAME="nvim"
WINDOW_2_NAME="scratch"
DEFAULT_WINDOW=1

# Rename the initial window
tmux rename-window -t "${SESSION_NAME}:1" "$WINDOW_1_NAME"

# Create second window in the same directory as the session
tmux new-window -dt "${SESSION_NAME}:2" -n "$WINDOW_2_NAME" -c "$SESSION_PATH"

# Return focus to first window
tmux select-window -t "${SESSION_NAME}:${DEFAULT_WINDOW}"
