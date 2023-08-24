
Write-Output '> Setting up scoop...'
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
Invoke-RestMethod get.scoop.sh | Invoke-Expression


Write-Output '> Setting up scoop buckets...'
scoop install git

# Install scoop buckets
Write-Output '> Installing scoop buckets...'
scoop bucket add extras
scoop bucket add nerd-fonts

# Install scoop packages
Write-Output '> Installing scoop packages...'
scoop install aria2

# Essentials
Write-Output '> Installing essentials...'
scoop install gh z sudo

# Development
Write-Output '> Installing development tools...'
scoop install vscode neovim pnpm

# Installing Rust
Write-Output '> Installing rustup...'
scoop install rustup

# For neovim
Write-Output '> Installing neovim plugins...'
scoop install extras/vcredist2022 make fd ripgrep
scoop uninstall vcredist2022

# Fonts
Write-Output '> Installing fonts...'
scoop install CascadiaCode-NF

# Powershell Tools
Write-Output '> Installing powershell tools...'
scoop install starship psreadline terminal-icons

# Set up prisma format for nvim
Write-Output '> Setting up prisma format... (Setting this up use in neovim)'
git clone https://github.com/prisma/prisma-engines.git "./prisma-engines"
Set-Location prisma-engines
cargo build --release
Move-Item -Path ".\target\release\prisma-fmt.exe" -Destination "$HOME\.config\bin" -Force
Set-Location ..
Remove-Item ".\prisma-engines" -Recurse -Force

# Set up exa - ls replacement
Write-Output '> Setting up exa...'
git clone https://github.com/ogham/exa.git "./exa"
Set-Location exa
cargo build --release
Move-Item -Path ".\target\release\exa.exe" -Destination "$HOME\.config\bin" -Force
Set-Location ..
Remove-Item ".\exa" -Recurse -Force

# Intall Nightly Rust
Write-Output '> Installing nightly rust...'
rustup update
rustup toolchain install nightly
