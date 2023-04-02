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
scoop install extras/vcredist2022 make fd ripgrep
scoop uninstall vcredist2022

# Fonts
scoop install CascadiaCode-NF

# Powershell Tools
scoop install starship psreadline terminal-icons

# Set up prisma format for nvim
git clone https://github.com/prisma/prisma-engines.git "$HOME\dotfiles"
cd prisma-engines
cargo build --release
Move-Item -Path "$HOME\dotfiles\prisma-engines\target\prisma-fmt.exe" "$HOME\.config\bin"
Remove-Item -Path "$HOME\dotfiles\prisma-engines" 

# Not sure how to automatically add this to the path

# Set up exa - ls replacement
git clone https://github.com/ogham/exa.git "$HOME\dotfiles"
cd exa
cargo build --release
Move-Item -Path "$HOME\dotfiles\exa\target\release\exa.exe" "$HOME\.config\bin"
Remove-Item -Path "$HOME\dotfiles\exa"
