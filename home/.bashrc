[[ -f "$HOME/.config/env" ]] && source "$HOME/.config/env"

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export EDITOR=nvim
export GIT_EDITOR=nvim
export VISUAL=nvim
export MANPAGER="nvim +Man!"

export SECOND_BRAIN="$HOME/second-brain"

export PATH="$HOME/.local/bin:$PATH"

export PATH="$HOME/.cargo/bin:$PATH"
. "$HOME/.cargo/env"

export PATH="$PATH:$HOME/.turso"

eval "$(mise activate bash)"
