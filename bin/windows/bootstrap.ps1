Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
irm get.scoop.sh | iex


scoop install git

scoop bucket add extras
scoop bucket add nerd-fonts

scoop install aria2

# Essentials
scoop install git gh z sudo

# Development
scoop install windows-terminal vscode firefox-developer neovim

# For neovim
scoop install extras/vcredist2022
scoop uninstall vcredist2022

# Fonts
scoop install CascadiaCode-NF

# Powershell Tools
scoop install starship psreadline terminal-icons