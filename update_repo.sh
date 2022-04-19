#!/usr/bin/env bash

# neovim
cp -r ~/.config/nvim/* nvim/ 2&> /dev/null

# tmux
cp -r ~/.config/tmux/* tmux/ 2&> /dev/null
cp ~/.config/tmux/.tmux.conf tmux/.tmux.conf 2&> /dev/null

# fish
cp -r ~/.config/fish/* fish/ 2&> /dev/null

# kitty
cp -r ~/.config/kitty/* kitty/ 2&> /dev/null

# system
cp ~/.config/system/* system/ 2&> /dev/null

# git config
cp ~/.gitconfig .gitconfig 2&> /dev/null

# deprecated
cp ~/.config/alacritty/* alacritty/ 2&> /dev/null
cp ~/.config/emacs/*.el emacs/ 2&> /dev/null
cp ~/.config/zsh/.zshrc zsh/ 2&> /dev/null
cp ~/.zshenv zsh/ 2&> /dev/null

# brew
switch (uname)
    case Darwin
        brew list --formula > brew_output.txt
        brew list --cask > brew_cask_output.txt
    case '*'
end
