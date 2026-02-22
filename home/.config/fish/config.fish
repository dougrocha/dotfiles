set -U fish_greeting

set -gx EDITOR nvim
set -gx GIT_EDITOR nvim
set -gx VISUAL nvim

set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_STATE_HOME "$HOME/.local/state"

set -gx SECOND_BRAIN "$HOME/second-brain"

abbr --add vim nvim
abbr --add lg lazygit
abbr --add cat bat
abbr --add tm 'tmux new-session -A -s default'

alias cd z

fzf --fish | source

starship init fish | source
zoxide init fish | source

# uv
fish_add_path "$HOME/.local/bin"
