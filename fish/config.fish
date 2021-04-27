alias vim='nvim'
alias rmd='rm -rf'

set EDITOR                  nvim

set FZF_DEFAULT_COMMAND     'rg --files --follow --hidden --no-ignore -g "!{.DS_Store,.cache,venv,.git}" 2> /dev/null'
set FZF_CTRL_T_COMMAND      $FZF_DEFAULT_COMMAND
set FZF_DEFAULT_OPTS        '--reverse --height 50%'
set FZF_CTRL_T_OPTS         '--preview "bat --style=numbers --color=always --line-range :500 {}"'

set   -g   fish_user_paths   "/Users/viraat-chandra/Library/Python/3.7/bin"   $fish_user_paths
set   -g   fish_user_paths   "/usr/local/opt/llvm/bin"                       $fish_user_paths
set   -g   fish_user_paths   "/usr/local/sbin"                               $fish_user_paths
# set PATH                    $PATH /Users/viraat-chandra/Library/Python/3.7/bin/
# set PATH                    $PATH /usr/local/opt/llvm/bin/

function setup_fish_colors
    # set -U fish_greeting   Stars\x20\x3a\x29
    set -U fish_greeting            " Stars :)"
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

    echo -sn ' '

    if set -q SSH_TTY
        echo -sn (set_color -o $ssh_color) '$ '
    else
        echo -sn (set_color -o $target_color) '$ '
    end
    set_color normal

    set -l CWD (basename $PWD)
    if [ $CWD != 'viraat-chandra' ]
        echo -sn (set_color normal) (basename $PWD) ' '
    end

    echo -ns (set_color -o $target_color) '-> '
    set_color normal
end

function tmux --description 'Tmux multiplexer'
    command tmux -f ~/.config/tmux/.tmux.conf $argv
end

function tree --description 'Tree'
    command tree -C -I 'venv|.git|__pycache__' $argv
end

function vm_ubuntu_start --description 'Start Ubuntu VM (VMWare)'
    command vmrun -T fusion start "Virtual Machines.localized/Ubuntu 64-bit.vmwarevm/Ubuntu 64-bit.vmx" nogui $argv
end

function vm_ubuntu_stop --description 'Stop Ubuntu VM (VMWare)'
    command vmrun -T fusion stop "Virtual Machines.localized/Ubuntu 64-bit.vmwarevm/Ubuntu 64-bit.vmx" soft $argv
end

function vm_list_running --description 'List Running VMs (VMWare)'
    command vmrun -T ws list $argv
end

# pyenv config
pyenv init - | source
