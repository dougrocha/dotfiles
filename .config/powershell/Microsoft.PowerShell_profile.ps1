# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

Import-Module Terminal-Icons
Import-Module PSReadLine

Import-Module "$HOME\dotfiles\.config\powershell\completions\fnm.ps1"
Import-Module "$HOME\dotfiles\.config\powershell\completions\rustup.ps1"

# Alias
Set-Alias vim nvim
Set-Alias ll ls
Set-Alias g git
Set-Alias find which
Set-Alias lg lazygit

# Env
$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineOption -EditMode Windows

# Utilities
function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

fnm env --use-on-cd | Out-String | Invoke-Expression
Invoke-Expression (&starship init powershell)