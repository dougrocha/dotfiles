if test -f "$HOME/.config/env"
    source "$HOME/.config/env"
end

if test -f "$HOME/.config/shell/env"
    source "$HOME/.config/shell/env"
end

fish_add_path -P "$HOME/.local/bin"
fish_add_path -P "$HOME/.opencode/bin"
fish_add_path -P "$HOME/.grok/bin"

# Regenerates the cached init script when the tool's binary is newer than it.
function source_init_cache
    set -l bin (command -s $argv[1]); or return
    set -l cache "$HOME/.cache/fish/init-$argv[1].fish"
    if not test -s $cache; or test $bin -nt $cache
        mkdir -p (path dirname $cache)
        $argv >$cache.$fish_pid; and mv -f $cache.$fish_pid $cache
    end
    source $cache
end

if status is-interactive
    set -g fish_greeting

    abbr --add vim nvim
    abbr --add lg lazygit
    abbr --add cat bat
    abbr --add tm 'tmux new-session -A -s default'
    abbr --add mup 'MISE_MINIMUM_RELEASE_AGE=0 mise up'

    source_init_cache fzf --fish
    source_init_cache starship init fish --print-full-init
    source_init_cache zoxide init fish

    alias cd z

    # Not cached, because the output embeds the current PATH.
    mise activate fish | source
else
    mise activate fish --shims | source
end
