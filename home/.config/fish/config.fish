set -U fish_greeting

set -gx EDITOR nvim
set -gx VISUAL code

abbr --add vim nvim
abbr --add lg lazygit

alias cd z

fzf --fish | source

starship init fish | source
zoxide init fish | source

# uv
fish_add_path "/Users/douglasrocha/.local/bin"
