#!/usr/bin/env bash

# disable press-and-hold in favour of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# faster scrolling by increasing key-repeat rate
# defaults write NSGlobalDomain InitialKeyRepeat -int 20
defaults write NSGlobalDomain KeyRepeat -int 1

