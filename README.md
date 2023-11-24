# My Dotfiles

Disclaimer: This is currently my barebones setup. I will add my windows config later. For now, this is only for MacOS.

## Table of Contents

- [My Dotfiles](#my-dotfiles)
  - [Table of Contents](#table-of-contents)
  - [Setup](#setup)
    - [Install Font (I use Caskaydia Cove Nerd Font)](#install-font-i-use-caskaydia-cove-nerd-font)
    - [Mac OSX](#mac-osx)
    - [Windows Setup](#windows-setup)

## Setup

Dotfiles must live in `~/.dotfiles`

```bash
git clone git@github.com:dougrocha/dotfiles.git ~/.dotfiles

cd ~/.dotfiles
```

### Install Font (I use Caskaydia Cove Nerd Font)

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

```powershell
# Install Dependencies
.\bin\windows\bootstrap.ps1

# Stow all files
.\bin\windows\stow.ps1
```
