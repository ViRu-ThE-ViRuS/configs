# vim:  commentstring=#%s
alias vim='SUDO_ASKPASS=~/.config/system/pw.sh nvim'
alias rmd='rm -rf'
alias cat='bat --theme=Coldark-Dark'
alias icat='kitty +kitten icat'
alias ssh='kitty +kitten ssh'
alias pip='pip3'

set -xg EDITOR              nvim
set -xg LANG                en_US.UTF-8
set -xg LC_CTYPE            en_US.UTF-8

# fzf
set FZF_DEFAULT_COMMAND     'rg --files --follow --smart-case --hidden --no-ignore -g "!{.DS_Store,.cache,venv,.git,.clangd,.ccls-cache,*.o,build,*.dSYM}" 2> /dev/null'
set FZF_DEFAULT_OPTS        '--reverse --height 50%'
set FZF_CTRL_T_COMMAND      $FZF_DEFAULT_COMMAND
set FZF_CTRL_T_OPTS         '--preview "bat --style=numbers,changes --color always --theme Coldark-Dark --line-range :500 {}"'

# macos : viraat-t2t
set fish_user_paths         $fish_user_paths "/opt/homebrew/bin/"
set fish_user_paths         $fish_user_paths "/Users/viraat-chandra/Library/Python/3.9/bin"
# set fish_user_paths         $fish_user_paths "/opt/homebrew/opt/llvm/bin"
# set -xg SUDO_ASKPASS        ~/.config/system/pw.sh # make this nvim specific

# rust setup
set -xg CARGO_HOME          ~/.rust/cargo/
set -xg RUSTUP_HOME         ~/.rust/rustup/
set fish_user_paths         $fish_user_paths ~/.rust/cargo/bin/

function setup_fish_colors
    set -U fish_greeting              " Stars :)"
    set -U fish_color_command         eee8d5
    set -U fish_color_autosuggestion  586e75
    set -U fish_color_param           93a1a1
    set -U fish_color_error           c82510
    set -U fish_color_redirection     6c71c4

    set -U LSCOLORS     xxfxcxdxbxegedabagacad
end

function fish_prompt
    set -l status_copy $status
    set -l target_color 10c891
    set -l ssh_color    1075c8

    if not set -q VIRTUAL_ENV
        echo -sn ' '
    end

    if set -q SSH_TTY
        echo -sn (set_color -o $ssh_color) '$'
    else
        echo -sn (set_color -o $target_color) '$'
    end

    set -l CWD (basename $PWD)
    if [ $CWD != 'viraat-chandra' ]
        echo -sn ' ' (set_color normal) (basename $PWD)
    end

    set -l GIT (fish_git_prompt)
    if [ $GIT ]
        echo -sn (set_color normal) (fish_git_prompt)
    end

    echo -ns (set_color -o $target_color) ' -> '
    set_color normal
end

function tmux --description 'tmux multiplexer'
    command tmux -f ~/.config/tmux/.tmux.conf $argv
end

function vmux --description 'tmux launch/attach session vir'
    command tmux -f ~/.config/tmux/.tmux.conf attach -t vir $argv || tmux -f ~/.config/tmux/.tmux.conf new -s vir $argv
end

function tree --description 'tree'
    command tree -C -I 'node_modules|venv|.git|__pycache__' $argv
end

function codelldb --description 'launch codelldb with custom config'
    ~/.local/codelldb/adapter/codelldb --port 13000
end

function python --description 'launch python'
    # if test -e "$VIRTUAL_ENV"
    #    command python3 $argv
    #    return
    # end

    if command -sq 'ipython'
        command ipython $argv
    else
        command python3 $argv
    end
end

