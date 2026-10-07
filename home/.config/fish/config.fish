if test -f "$HOME/.config/env"
    source "$HOME/.config/env"
end

if test -f "$HOME/.config/shell/env"
    source "$HOME/.config/shell/env"
end

fish_add_path -P "$HOME/.local/bin"
fish_add_path -P "$HOME/.opencode/bin"

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

    mise activate fish | source
else
    mise activate fish --shims | source
end
