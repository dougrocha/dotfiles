# My Dotfiles

## Table of Contents

- [My Dotfiles](#my-dotfiles)
  - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
    - [Mac OSX](#mac-osx)
    - [Windows Setup](#windows-setup)
    - [After installation](#after-installation)

Do not use this yourself. It likes to break almost 100% of the time.

---

## Usage

Clone this repo. Here I assume that you have cloned the repo into a `./config` directory which lives in your home directory.

```bash
git clone https://github.com/dougrocha/dotfiles.git
```

Install fonts.

I mainly use Caskaydia Cove or FiraCode.

[Nerd Fonts](https://www.nerdfonts.com/font-downloads)

---

### Mac OSX

Install brew [Homebrew](https://brew.sh)

Install all brew files.

```bash
brew bundle install --file=~/config/Brewfile
```

Make Fish default shell.

```bash
 echo /usr/local/bin/fish | sudo tee -a /etc/shells

 chsh -s /usr/local/bin/fish
```

Install all fisher plugins.

```bash
fisher update
```

Link all linkable things.

```bash
ln -sv "~/.config/.gitconfig" ~
```

---

### Windows Setup

Install powershell terminal in the Microsoft Store.

Install Scoop.

```bash
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
irm get.scoop.sh | iex
```

Setup environment

```bash
scoop bucket add extras
scoop bucket add versions
scoop bucket add main
scoop bucket add nerd-fonts
scoop bucket add games
scoop install 7zip discord gcc git gzip nvm obsidian osu psreadline python ripgrep starship steam terminal-icons vcredist2022 vcredist vscode windows-terminal winget yarn z wget
scoop install neovim-nightly
```

Install Vim-Plug [Vim-Plug](https://github.com/junegunn/vim-plug)

Create links for file paths.

Please use **Command Prompt** for these commands

If you are using powershell prefix these commands with `cmd /c`

```cmd
mklink /D C:\Users\slash\AppData\Local\Yarn\Data\global C:\Users\slash\.config\yarn\global
mklink /D C:\Users\slash\AppData\Local\nvim C:\Users\slash\.config\nvim
mklink /D C:\Users\slash\.gitconfig C:\Users\slash\.config\.gitconfig
mklink C:\Users\slash\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 C:\Users\slash\powershell\Microsoft.PowerShell_profile.ps1
```

Configure yarn paths

```bash
yarn config set prefix C:/Users/slash/scoop/apps/yarn/current
yarn config set global-folder C:/Users/slash/scoop/apps/yarn/current/global
yarn config set cache-folder C:/Users/slash/scoop/apps/yarn/current/cache
yarn global add neovim diagnostic-languageserver
```

### After installation

Install Node LTS (Long Term Support)

```bash
nvm install lts
nvm use lts
```

After (TMP) Run in Powershell

```powershell
New-Item -Path 'C:\Users\slash\Documents\PowerShell\Microsoft.PowerShell_profile.ps1' -ItemType File
cmd /c mklink C:\Users\slash\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 C:\Users\slash\powershell\Microsoft.PowerShell_profile.ps1
```
