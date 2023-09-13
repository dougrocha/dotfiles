function ls_alias { eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group }
function la_alias { eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group -a }
function ll_alias { eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group -al }
function lr_alias { eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse }
function lra_alias { eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse --all }
function lt_alias { eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse --tree }
function lta_alias { eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group --recurse --tree --all }

Set-Alias -Name ls -Value ls_alias
Set-Alias -Name la -Value la_alias
Set-Alias -Name ll -Value ll_alias
Set-Alias -Name lr -Value lr_alias
Set-Alias -Name lra -Value lra_alias
Set-Alias -Name lt -Value lt_alias
Set-Alias -Name lta -Value lta_alias