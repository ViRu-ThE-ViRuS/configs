# ViRu-ThE-ViRuS
### Custom Configs FTW!!

Here are the configurations I use for my dev setups.
The Installation instructions are for *MacOS* as of yet.

#### Kitty
- I use Kitty as my primary terminal, its fast, hash
  everything i was missing in alacritty, so its my primary candidate for
  replacing iTerm2.
The configuration folder is `kitty/`, to be placed in `~/.config/`

#### iTerm2
- I use iTerm2 as (backup) Terminal.app on MacOS doesn't support truecoloring as of yet
- The profile configuration is `Virus.json`

#### Alacritty
- I am experimenting with Alacritty as my primary terminal, because it is
  significantly faster in my uses and doesn't have major sideeffects other than
  the lack of tabs in it and font ligatures
- `$ brew cask install alacritty`
The configuration file is `alacritty.yml` located in `~/.config/alacritty/`

#### NeoVim
- I use NeoVim, because, well... I use a Mac
- `$ brew install neovim`

The configuration file is `init.vim` located in `~/.config/nvim/`

#### tmux
- I use Tmux for window management
- `$ brew install tmux`

The configuration file is `.tmux.conf` located in `~/.config/tmux/`

#### zsh
- I use zsh as my secondary bash prompt...
- It is installed by default on modern versions of *MacOS*

The configuration file is `.zshrc` located in `~/.config/zsh/`
The `.zshenv` file is located in `~/`

#### fish
- I use fish as my primary bash prompt...
- `$ brew install fish`

The configuration files are in `fish` located in `~/.config/fish/`

### MISC
- Brew list output in `brew_output.txt`
- I use Fira Code font (Fira Code, Retina, 14pts)
- I use Tiles window manager on MacOS
- Periodically use `brew cleanup ; brew doctor`
- Periodically update brew casks after checking `brew cask outdated`
- A deprecated vim configuration is present... reference NeoVim configuration
    for updates
    - vim configuration file is `.vimrc`
