function New-Link ($target, $link) {
    New-Item -Path $link -ItemType SymbolicLink -Value $target -Force
}

Write-Output "> Home: $HOME"
Write-Output "> Creating symlinks..."

New-Link "$HOME\dotfiles\.config\starship.toml" "$HOME\.config\starship.toml"
New-Link "$HOME\dotfiles\.gitignore_global" "$HOME\.gitignore_global"

New-Link "$HOME\dotfiles\.config\powershell\Microsoft.PowerShell_profile.ps1" $Profile

New-Link "$HOME\dotfiles\.config\nvim" "$HOME\AppData\Local\nvim"

Write-Output "> Done."