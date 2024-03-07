function New-Link ($target, $link) {
    New-Item -Path $link -ItemType SymbolicLink -Value $target -Force
}

if (-not (Test-Path "$HOME\.config")) {
    Write-Output "> Creating .config directory..."
    New-Item -Path "$HOME\.config" -ItemType Directory
}

Write-Output "> Home: $HOME"
Write-Output "> Creating symlinks..."

New-Link "$HOME\dotfiles\nvim" "$HOME\AppData\Local\nvim"

New-Link "$HOME\dotfiles\wezterm" "$HOME\.config\wezterm"
New-Link "$HOME\dotfiles\neofetch" "$HOME\.config\neofetch"
New-Link "$HOME\dotfiles\starship.toml" "$HOME\.config\starship.toml"

Write-Output "> Copying default .gitconfig..."
Copy-Item -Verbose -Path "$HOME\dotfiles\.gitconfig" -Destination "$HOME\.gitconfig"
Write-Output "> DO NOT FORGET TO SET SSH TOKEN"

Write-Output "> Setting up $PROFILE..."

Set-Content -Path $PROFILE.CurrentUserCurrentHost -Value ""
Add-Content -Path $PROFILE.CurrentUserCurrentHost -Value ". $env:USERPROFILE\dotfiles\powershell\user_profile.ps1"


# run a ps1 file from here
Write-Output "> Adding completions..."
. "$HOME\dotfiles\bin\windows\add-completions.ps1"

Write-Output "> Done."