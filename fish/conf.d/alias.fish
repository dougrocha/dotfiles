if status is-interactive
    # LS replacements using Exa
    abbr --add ls='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group $args'
    abbr --add la='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group -a $args'
    abbr --add lt='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse --tree $args'
    abbr --add lr='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse $args'
    abbr --add ll='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group -al $args'
    abbr --add lra='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse --all $args'
    abbr --add lta='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse --tree --all $args'

    # Alias for bat
    abbr --add cat='batcat'

    # Git aliases
    abbr --add lg='lazygit'

    # Neovim
    abbr --add vim='nvim'

    # Zoxide
    abbr --add cd='z'
end