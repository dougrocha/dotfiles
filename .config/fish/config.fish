set -x LANG en_US.UTF-8

if status is-interactive
    # Commands to run in interactive sessions can go here
end

if status is-login
    # Commands to run in login shells can go here
end

# LS replacements using Exa
alias ls='exa --icons'
alias la='ls -a'
alias ld='ls -D'
alias lt='exa -T --icons'

# Git aliases
alias lg='lazygit'

starship init fish | source
