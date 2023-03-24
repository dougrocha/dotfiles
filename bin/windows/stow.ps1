function make-link ($target, $link) {
    New-Item -Path $link -ItemType SymbolicLink -Value $target -Force
}

echo "Home: $HOME"
echo "Creating symlinks..."

make-link "$HOME\dotfiles\.config\starship.toml" "$HOME\.config\starship.toml"
make-link "$HOME\dotfiles\.gitignore_global" "$HOME\.gitignore_global"

make-link "$HOME\dotfiles\.config\powershell\Microsoft.PowerShell_profile.ps1" "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

make-link "$HOME\dotfiles\.config\nvim" "$HOME\AppData\Local\nvim"

echo "Done."