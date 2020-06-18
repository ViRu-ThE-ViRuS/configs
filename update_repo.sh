cp ~/.config/nvim/init.vim nvim/
cp -r ~/.config/tmux/* tmux/
cp ~/.config/alacritty/* alacritty/
cp -r ~/.config/fish/* fish/
cp -r ~/.config/kitty/* kitty/
cp ~/.config/zsh/.zshrc zsh/
cp ~/.zshenv zsh/

switch (uname)
    case Darwin
        brew list > brew_output.txt
    case '*'
end
