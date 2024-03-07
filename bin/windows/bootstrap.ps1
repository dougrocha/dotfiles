# Setup scoop if it doesnt exist. If it does, update scoop
if (Get-Command scoop -errorAction SilentlyContinue) {
    Write-Output "> Scoop already exists... Updating scoop"
    scoop update
    scoop status
}
else {
    Write-Output '> Setting up scoop...'
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
}

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
scoop install gh zoxide sudo fnm

# Development
Write-Output '> Installing development tools...'
scoop install neovim-nightly eza

# For neovim
Write-Output '> Installing neovim plugins...'
scoop install extras/vcredist2022 mingw coreutils make fd ripgrep gcc wget unzip gzip

# Powershell Tools
Write-Output '> Installing powershell and powershell tools...'
scoop install starship psreadline terminal-icons powershell wezterm

Write-Output '> Installing Firefox...'
winget install --id Mozilla.Firefox.DeveloperEdition --source winget

Write-Output '> Installing PowerToys...'
winget install --id Microsoft.PowerToys --source winget

# Set up prisma format for nvim
Write-Output '> Setting up prisma format... (Setting this up use in neovim)'
git clone https://github.com/prisma/prisma-engines.git "./prisma-engines"
Set-Location prisma-engines
cargo build --release --package prisma-fmt
Move-Item -Path ".\target\release\prisma-fmt.exe" -Destination "$HOME\.config\bin" -Force
Set-Location ..
Remove-Item ".\prisma-engines" -Recurse -Force

Write-Output '> Uninstalling vcredist2022...'
scoop uninstall vcredist2022