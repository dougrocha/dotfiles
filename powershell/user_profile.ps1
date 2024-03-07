# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

Import-Module Terminal-Icons
Import-Module PSReadLine

Import-Module "$HOME\dotfiles\powershell\completions\fnm.ps1"
Import-Module "$HOME\dotfiles\powershell\completions\rustup.ps1"
Import-Module "$HOME\dotfiles\powershell\alias.ps1"
Import-Module "$HOME\dotfiles\powershell\functions.ps1"
# Import completions
$files = Get-ChildItem -Path "$HOME\dotfiles\powershell\completions\*.ps1"
foreach ($file in $files) {
    Import-Module $file.FullName
}

# Alias
Set-Alias vim nvim
Set-Alias g git
Set-Alias find which
Set-Alias lg lazygit

# Env
$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"

# PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -EditMode Windows

fnm env --use-on-cd | Out-String | Invoke-Expression
Invoke-Expression (&starship init powershell)

Invoke-Expression (& { (zoxide init powershell | Out-String) })
