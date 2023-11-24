function New-Link ($target, $link) {
    New-Item -Path $link -ItemType SymbolicLink -Value $target -Force
}

Write-Output "> Home: $HOME"
Write-Output "> Creating symlinks..."

Write-Output "> Creating symlinks for dotfiles..."
New-Link "$HOME\dotfiles\.config" "$HOME\.config"

Write-Output "> Creating symlinks for git..."
New-Link "$HOME\dotfiles\.gitignore_global" "$HOME\.gitignore_global"

Write-Output "> Creating symlinks for neovim..."
New-Link "$HOME\.config\nvim" "$HOME\AppData\Local\nvim"

Write-Ouput  "> Creating symlinks for terminal profile settings..."
New-Link "$HOME\.config\terminal/settings.json" "$HOME\scoop\apps\windows-terminal\current\settings\settings.json" --Force

Write-Output "> Copying default .gitconfig..."
Copy-Item -Path "$HOME\dotfiles\.gitconfig" -Destination "$HOME\.gitconfig"
Write-Output "> DO NOT FORGET TO SET SSH TOKEN"

Write-Output "> Writing to $PROFILE..."
Add-Content -Path $PROFILE.CurrentUserCurrentHost -Value ". $env:USERPROFILE\.config\powershell\user_profile.ps1"

Write-Output "> Done."