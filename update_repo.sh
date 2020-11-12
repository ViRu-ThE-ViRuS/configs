cp ~/.config/nvim/init.vim nvim/
cp -r ~/.config/tmux/* tmux/
cp ~/.config/tmux/.tmux.conf tmux/.tmux.conf
cp ~/.config/alacritty/* alacritty/
cp -r ~/.config/fish/* fish/
cp -r ~/.config/kitty/* kitty/
cp ~/.config/emacs/*.el emacs/
cp ~/.config/zsh/.zshrc zsh/
cp ~/.zshenv zsh/

switch (uname)
    case Darwin
        brew list --formula > brew_output.txt
        brew list --cask > brew_cask_output.txt
    case '*'
end
