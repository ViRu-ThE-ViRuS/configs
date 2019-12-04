source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
export PS1="%10F\$[->]%f "

alias vm_ubuntu_start='vmrun -T fusion start "Virtual Machines.localized/Ubuntu 64-bit.vmwarevm/Ubuntu 64-bit.vmx" nogui'
alias vm_ubuntu_stop='vmrun -T fusion stop "Virtual Machines.localized/Ubuntu 64-bit.vmwarevm/Ubuntu 64-bit.vmx" soft'
alias vm_list_running='vmrun -T ws list'
