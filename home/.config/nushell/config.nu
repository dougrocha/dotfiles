$env.config.show_banner = false
$env.config.buffer_editor = "nvim"

alias lg = lazygit
alias vim = nvim
alias as = aerospace

alias nu-open = open
alias open = ^open

source ~/.cache/.zoxide.nu
alias cd = z

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
source $"($nu.home-path)/.cargo/env.nu"
