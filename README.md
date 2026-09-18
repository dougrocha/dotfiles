# Dotfiles

- **`home/`** - Dotfiles
- **`default/`** - System-level configurations
- **`install/`** - Installation scripts
- **`install/links`** - Stow

## Setup

```sh
git clone git@github.com:dougrocha/dotfiles.git
cd dotfiles

./setup
```

## Linking

```sh
./link            # deploy
./link -n         # dry run
./link --prune    # deploy, and clean up links no longer needed
./link --help     # all options
```

This is cause stow is too basic, and other tools are too complicated to use and installed.

I don't want to be locked in and Odin is awesome.

Portfolio: [Portfolio](https://www.dougrocha.com)

## Inspiration

- [Omarchy](https://omarchy.org/)
- [Maria Solano](https://www.mariasolos.com/)
