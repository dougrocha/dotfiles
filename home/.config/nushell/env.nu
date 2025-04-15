use std "path add"

$env.EDITOR = 'nvim'

$env.PNPM_HOME = $"($env.HOME)/Library/pnpm"
path add $env.PNPM_HOME

path add /usr/local/bin/
path add ($env.HOME | path join .cargo bin)
$env.PATH = ($env.PATH | uniq)

path add /Library/Frameworks/Python.framework/Versions/3.9/bin

$env.ZK_NOTEBOOK_DIR = ($env.HOME | path join second-brain)

use ./fnm.nu

mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu
zoxide init nushell | save -f ~/.cache/.zoxide.nu
