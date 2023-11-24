# Aliases
Set-Alias vim nvim
Set-Alias g git
Set-Alias find which
Set-Alias lg lazygit

# Alias using Eza to replace ls
function ls_alias { eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group $args }
function la_alias { eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group -a $args }
function ll_alias { eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group -al $args }
function lr_alias { eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse $args }
function lra_alias { eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse --all $args }
function lt_alias { eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse --tree $args }
function lta_alias { eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse --tree --all $args }

Set-Alias -Name ls -Value ls_alias
Set-Alias -Name la -Value la_alias
Set-Alias -Name ll -Value ll_alias
Set-Alias -Name lr -Value lr_alias
Set-Alias -Name lra -Value lra_alias
Set-Alias -Name lt -Value lt_alias
Set-Alias -Name lta -Value lta_alias