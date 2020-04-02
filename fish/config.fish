set -Ux LSCOLORS xxfxcxdxbxegedabagacad
set -Ux EDITOR nvim

function fish_prompt --description 'Fish prompt'
    set_color green
    echo -n '$[->] '
end

function vim --description 'Editor of choice'
    command nvim $argv
end

function tmux --description 'Tmux multiplexer'
    command tmux -f ~/.config/tmux/.tmux.conf $argv
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
