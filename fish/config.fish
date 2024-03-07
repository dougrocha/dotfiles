set -x LANG en_US.UTF-8

if status is-interactive
    # Commands to run in interactive sessions can go here
end

if status is-login
    # Commands to run in login shells can go here
end

# LS replacements using Exa
alias ls='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group $args'
alias la='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group -a $args'
alias lt='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse --tree $args'
alias lr='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse $args'
alias ll='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group -al $args'
alias lra='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse --all $args'
alias lta='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse --tree --all $args'

# Alias for bat
alias cat='bat'

# Git aliases
alias lg='lazygit'

# Neovim
alias vim='nvim'

starship init fish | source
