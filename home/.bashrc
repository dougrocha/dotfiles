[[ -f "$HOME/.config/env" ]] && source "$HOME/.config/env"

[[ -f "$HOME/.config/shell/env" ]] && source "$HOME/.config/shell/env"

export PATH="$HOME/.local/bin:$PATH"

# Adds ~/.cargo/bin to PATH.
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

command -v mise >/dev/null 2>&1 && eval "$(mise activate bash)"
