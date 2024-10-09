# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

Set-Alias vim nvim
Set-Alias lg lazygit

function which($name) { Get-Command $name -ErrorAction SilentlyContinue | Select-Object Definition }

fnm env --use-on-cd | Out-String | Invoke-Expression
Invoke-Expression (&starship init powershell)

Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Has to go after otherwise it does not work
Set-Alias -Name cd -Value z -Option AllScope
Set-Alias -Name cat -Value bat -Option AllScope
Set-Alias -Name ls -Value eza -Option AllScope