cp ~/.config/nvim/init.vim .
cp ~/.config/tmux/.tmux.conf .
cp ~/.config/alacritty/alacritty.yml .
cp -r ~/.config/fish .
cp -r ~/.config/kitty .

cp ~/.config/zsh/.zshrc .
cp ~/.zshenv .

switch (uname)
    case Darwin
        brew list > brew_output.txt
    case '*'
end
