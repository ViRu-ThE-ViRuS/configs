#!/usr/bin/env bash

# nvim
sudo -A cp -r nvim/* ~/.config/nvim/

# tmux
cp -r tmux/* ~/.config/tmux/
cp tmux/.tmux.conf ~/.config/tmux/

# fish
sudo -A cp -r fish/* ~/.config/fish/

# kitty
cp -r kitty/* ~/.config/kitty/

# system
cp -r system/* ~/.config/system/

# git config
cp .gitconfig ~/.gitconfig

# deprecated
cp alacritty/* ~/.config/alacritty/
cp emacs/init.el ~/.config/emacs/init.el
cp zsh/.zshrc ~/.config/zsh/
cp zsh/.zshenv ~/.zshenv

