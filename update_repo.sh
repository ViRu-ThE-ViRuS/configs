cp -r ~/.config/nvim/* nvim/ 2&> /dev/null
cp -r ~/.config/tmux/* tmux/ 2&> /dev/null
cp ~/.config/tmux/.tmux.conf tmux/.tmux.conf 2&> /dev/null
cp ~/.config/alacritty/* alacritty/ 2&> /dev/null
cp -r ~/.config/fish/* fish/ 2&> /dev/null
cp -r ~/.config/kitty/* kitty/ 2&> /dev/null
cp ~/.config/emacs/*.el emacs/ 2&> /dev/null
cp ~/.config/zsh/.zshrc zsh/ 2&> /dev/null
cp ~/.zshenv zsh/ 2&> /dev/null

switch (uname)
    case Darwin
        brew list --formula > brew_output.txt
        brew list --cask > brew_cask_output.txt
    case '*'
end
