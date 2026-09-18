if test -f "$HOME/.config/env"
    source "$HOME/.config/env"
end

set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_STATE_HOME "$HOME/.local/state"

if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end

fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/.opencode/bin"

set -gx EDITOR nvim
set -gx GIT_EDITOR nvim
set -gx VISUAL nvim
set -gx MANPAGER "nvim +Man!"
set -gx PAGER bat

set -gx SECOND_BRAIN "$HOME/second-brain"

if status is-interactive
    mise activate fish | source
else
    mise activate fish --shims | source
end

if status is-interactive
    set -g fish_greeting

    abbr --add vim nvim
    abbr --add lg lazygit
    abbr --add cat bat
    abbr --add tm 'tmux new-session -A -s default'
    abbr --add mup 'MISE_MINIMUM_RELEASE_AGE=0 mise up'

    fzf --fish | source
    starship init fish | source
    zoxide init fish | source

    alias cd z
end
