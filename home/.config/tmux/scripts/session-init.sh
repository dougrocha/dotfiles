#!/usr/bin/env bash
# Auto-initialize new tmux sessions with named windows
# Called by after-new-session hook in ~/.config/tmux/hooks.conf

# Debug logging (set to 1 to enable, 0 to disable)
DEBUG=0
LOG_FILE="$HOME/.config/tmux/session-init.log"

log_debug() {
    if [ "$DEBUG" -eq 1 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
    fi
}

SESSION_NAME="$1"
SESSION_PATH="$2"

WINDOW_1_NAME="nvim"
WINDOW_2_NAME="scratch"
DEFAULT_WINDOW=1

log_debug "=== Session Init Started ==="
log_debug "SESSION_NAME: '$SESSION_NAME'"
log_debug "SESSION_PATH: '$SESSION_PATH'"
log_debug "All args: $*"
log_debug "Arg count: $#"

# Rename the initial window
log_debug "Renaming window to '$WINDOW_1_NAME'"
if tmux rename-window -t "${SESSION_NAME}:1" "$WINDOW_1_NAME" 2>&1 | tee -a "$LOG_FILE"; then
    log_debug "✓ Rename successful"
else
    log_debug "✗ Rename failed with exit code: $?"
fi

# Create second window in the same directory as the session
log_debug "Creating window '$WINDOW_2_NAME' in directory '$SESSION_PATH'"
if tmux new-window -dt "${SESSION_NAME}:2" -n "$WINDOW_2_NAME" -c "$SESSION_PATH" 2>&1 | tee -a "$LOG_FILE"; then
    log_debug "✓ Window creation successful"
else
    log_debug "✗ Window creation failed with exit code: $?"
fi

# Return focus to first window
log_debug "Selecting window ${DEFAULT_WINDOW}"
if tmux select-window -t "${SESSION_NAME}:${DEFAULT_WINDOW}" 2>&1 | tee -a "$LOG_FILE"; then
    log_debug "✓ Window selection successful"
else
    log_debug "✗ Window selection failed with exit code: $?"
fi

log_debug "=== Session Init Completed ==="

# Optional: Uncomment to run commands in specific windows
# tmux send-keys -t "${SESSION_NAME}:1" "nvim ." C-m
