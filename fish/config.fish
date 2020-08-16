set fish_greeting   Stars\x20\x3a\x29

set LSCOLORS    xxfxcxdxbxegedabagacad
set EDITOR      nvim

set FZF_DEFAULT_COMMAND     'rg --files --follow --hidden -g "!{venv,.git}" 2> /dev/null'
set FZF_CTRL_T_COMMAND      'rg --files --follow --hidden -g "!{venv,.git}" 2> /dev/null'

set ZDOTDIR     ~/.config/zsh
# set GOPATH      ~/.dev/go
# set GOBIN       $GOPATH/bin

set PATH            $PATH /Users/viraat-chandra/Library/Python/3.7/bin/
set PATH            $PATH /usr/local/opt/llvm/bin/

function fish_prompt
    set -l status_copy $status
    set -l target_color 10c891
    set -l ssh_color    1075c8

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

alias vim='nvim'
alias rmd='rm -rf'

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
