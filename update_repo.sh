#!/usr/bin/env bash
# vim: ft=bash :

# neovim
if [ -e ~/.config/nvim/ ]; then
  echo "Copying neovim config..."
  rm -rf nvim/*
  cp -r ~/.config/nvim/* nvim/
fi

# tmux
if [ -e ~/.config/tmux/ ]; then
  echo "Copying tmux config..."
  rm -rf tmux/*
  cp -r ~/.config/tmux/* tmux/
  cp ~/.config/tmux/.tmux.conf tmux/.tmux.conf 2&> /dev/null
fi

# fish
if [ -e ~/.config/fish/ ]; then
  echo "Copying fish config..."
  rm -rf fish/*
  cp -r ~/.config/fish/* fish/
fi

# kitty
if [ -e ~/.config/kitty/ ]; then
  echo "Copying kitty config..."
  rm -rf kitty/*
  cp -r ~/.config/kitty/* kitty/
fi

# system
if [ -e ~/.config/system/ ]; then
  echo "Copying system config..."
  rm -rf system/*
  cp ~/.config/system/* system/
fi

# git config
cp ~/.gitconfig .gitconfig

uname=$(uname)
case "$uname" in
  Darwin)
    brew list --formula > system/brew_output.txt
    brew list --cask > system/brew_cask_output.txt
    ;;
  Linux)
    dconf dump / > system/dconf-settings.ini
    ;;
  *)
    echo "Unsupported OS: $uname"
    ;;
esac
