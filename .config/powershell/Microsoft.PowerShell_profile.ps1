# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

Import-Module Terminal-Icons
Import-Module PSReadLine

# Alias
Set-Alias vim nvim
Set-Alias ll ls
Set-Alias g git
Set-Alias find which

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
