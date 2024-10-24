if status is-interactive
    # LS replacements using Exa
    alias ls='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group $args'
    alias la='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group -a $args'
    alias lt='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse --tree $args'
    alias lr='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse $args'
    alias ll='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group -al $args'
    alias lra='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse --all $args'
    alias lta='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse --tree --all $args'

    # Alias for bat
    abbr --add cat batcat

    # Git aliases
    abbr --add lg lazygit

    # Neovim
    abbr --add vim nvim

    # Zoxide
    abbr --add cd z
end
