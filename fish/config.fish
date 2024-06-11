set -gx EDITOR (which nvim)

set -x LANG en_US.UTF-8

fish_add_path $PATH ~/.cargo/bin

source ~/.config/fish/themes/Catppuccin_Macchiato.fish


# LS replacements using Eza
alias ls="eza --color=always --icons --group-directories-first"
alias la='eza --color=always --icons --group-directories-first --all'
alias ll='eza --color=always --icons --group-directories-first --all --long'

# Alias for bat
alias cat='bat'

# Git aliases
alias lg='lazygit'

# Neovim
alias vim='nvim'

alias grep='rg'

zoxide init fish | source

starship init fish | source
