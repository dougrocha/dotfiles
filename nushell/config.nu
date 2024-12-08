fnm env --json | from json | load-env
$env.PATH = ($env.PATH | split row (char esep) | prepend $env.FNM_MULTISHELL_PATH)
$env.PATH = ($env.PATH | uniq)

$env.config = { 
    show_banner: false,
    shell_integration: {
        osc133: false
    }
}

alias lg = lazygit
alias vim = nvim

source ~/.zoxide.nu

alias cd = z
