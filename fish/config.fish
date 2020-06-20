set fish_greeting   Stars\x20\x3a\x29

set -Ux LSCOLORS    xxfxcxdxbxegedabagacad
set -Ux EDITOR      nvim

set -Ux FZF_DEFAULT_COMMAND 'rg --files --follow --hidden -g "!{venv,.git}" 2> /dev/null'
set -Ux FZF_CTRL_T_COMMAND 'rg --files --follow --hidden -g "!{venv,.git}" 2> /dev/null'

set -Ux ZDOTDIR     ~/.config/zsh
set -Ux GOPATH      ~/.dev/go
set -Ux GOBIN       $GOPATH/bin

set PATH            $PATH /Users/viraat-chandra/Library/Python/3.7/bin/
set PATH            $PATH /usr/local/Cellar/llvm/10.0.0_3/bin/

function fish_prompt
    set -l status_copy $status
    set -l target_color 10c891

    echo -sn (set_color -o $target_color) '$ '
    set_color normal

    set -l CWD (basename $PWD)
    if [ $CWD != 'viraat-chandra' ]
        echo -sn (set_color normal) (basename $PWD) ' '
    end

    echo -ns (set_color -o $target_color) '-> '
    set_color normal
end

alias vim='nvim'

function tmux --description 'Tmux multiplexer'
    command tmux -f ~/.config/tmux/.tmux.conf $argv
end

function tree --description 'Tree'
    command tree -C -I 'venv|.git' $argv
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
