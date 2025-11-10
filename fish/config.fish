# vim: ft=fish

# {{{ setup functions
function setup_base
  alias vim='nvim'
  alias rmd='rm -rf'
  alias cat='bat'
  alias icat='kitty +kitten icat'
  alias pip='pip3'
  alias python='python3'
  # alias ssh='kitty +kitten ssh'
end

function setup_fzf
  set -xg FZF_IGNORE_DIRS     '.DS_Store,.cache,venv,.git,.clangd,.ccls-cache,*.o,build,*.dSYM'
  set -xg FZF_DEFAULT_COMMAND 'rg --files --follow --smart-case --hidden --no-ignore -g "!{$FZF_IGNORE_DIRS}" 2> /dev/null'
  set -xg FZF_DEFAULT_OPTS    '--reverse --height 50%'
  set -xg FZF_CTRL_T_COMMAND  $FZF_DEFAULT_COMMAND
  set -xg FZF_CTRL_T_OPTS     '--preview "bat --style=numbers,changes --color always --line-range :500 {}"'
end

function setup_ssh
  # if test -z "$SSH_AUTH_SOCK"
    killall ssh-agent 1&> /dev/null
    eval (ssh-agent -c) > /dev/null
    set -xg SSH_AUTH_SOCK $SSH_AUTH_SOCK
    set -xg SSH_AGENT_PID $SSH_AGENT_PID

    # ssh-add ~/.ssh/id_rsa 1&> /dev/null
    for id in (ls $HOME/.ssh/id_* | grep -v ".pub")
      ssh-add $id 1&> /dev/null
    end

    if type -q docker
      docker login -u viraatc -p $TRT_GITLAB_API_TOKEN gitlab-master.nvidia.com &> /dev/null
    end
  # end
end
# }}}

# setup common options
set -xg EDITOR   nvim
set -xg LANG     en_US.UTF-8
set -xg LC_CTYPE en_US.UTF-8
set -xg LC_ALL   en_US.UTF-8
# set -xg LANG     en_US
# set -xg LC_CTYPE en_US
# set -xg LC_ALL   en_US
set fish_greeting ""

setup_base
setup_fzf

# setup os specific overrides
switch (uname)

  case Linux
    alias bat='batcat'
    set -xg DOCKER_BUILDKIT       1

  case Darwin
    alias cat='bat --theme=Coldark-Dark'
    alias vim='SUDO_ASKPASS=$HOME/.config/system/pw.sh nvim'
    set -xg FZF_CTRL_T_OPTS     '--preview "bat --style=numbers,changes --color always --theme Coldark-Dark --line-range :500 {}"'

  case '*'

end

# setup host specific overrides
switch (hostname)

  # the OG
  case Viraat-TT4.local
    set fish_user_paths           $fish_user_paths "/opt/homebrew/bin/"
    set fish_user_paths           $fish_user_paths "$HOME/Library/Python/3.9/bin"
    set fish_user_paths           $fish_user_paths "$HOME/.local/bin"

    nvm use v22 1&> /dev/null

  # mobile workstation
  case viraatc-mlt # storm
    set fish_user_paths           $fish_user_paths "/opt/homebrew/bin/"
    set fish_user_paths           $fish_user_paths "$HOME/.local/bin/"
    set fish_user_paths           $fish_user_paths "/Library/Frameworks/Python.framework/Versions/3.10/bin/"

    set fish_user_paths           $fish_user_paths "$HOME/.rustup/toolchains/stable-aarch64-apple-darwin/bin/"

    set -xg NVCF_API_KEY              "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"

    nvm use v22 1&> /dev/null
    setup_ssh

  # work desk workstation
  case nova
    set fish_user_paths           $fish_user_paths "$HOME/.local/bin/"
    set fish_user_paths           $fish_user_paths "/usr/local/cuda-12.1/bin/"
    setup_ssh

    alias rvim='nvim --remote-ui --server ip6-localhost:5757'

    # tensorrt
    set -xg GIT_TRT_ROOT          "$HOME/workspace/trt/git-trt/"
    set -xg MANPATH               $MANPATH "$HOME/workspace/trt/git-trt/man"
    set fish_user_paths           $fish_user_paths "$HOME/workspace/trt/git-trt/bin"

    # mlperf
    set -xg MLPERF_SCRATCH_PATH   "/home/viraatc/workspace/mlperf/mlperf_scratch_space/"

  # dev-container
  case dev
    set fish_user_paths           $fish_user_paths "$HOME/.local/bin/"

  case '*'

end

# {{{ core
function setup_fish_colors
  set -U fish_greeting             " Stars :)"
  set -U fish_color_command        eee8d5
  set -U fish_color_autosuggestion 586e75
  set -U fish_color_param          93a1a1
  set -U fish_color_error          c82510
  set -U fish_color_redirection    6c71c4
  set -U LSCOLORS     xxfxcxdxbxegedabagacad
end

function fish_prompt
  set -l status_copy  $status
  set -l target_color 10c891
  set -l ssh_color    da2f31
  set -l dev_color    009ece

  set -l HOST (hostname)
  set -l CWD (basename (pwd))
  set -l GIT (fish_git_prompt)

  if not set -q VIRTUAL_ENV
    echo -sn ' '
  end

  if set -q SSH_TTY
    echo -sn (set_color -o $ssh_color) '$'
  else if [ $HOST = 'dev' ]
    echo -sn (set_color -o $dev_color) '$'
  else
    echo -sn (set_color -o $target_color) '$'
  end

  if [ $CWD != $USER ]
    echo -sn ' ' (set_color normal) $CWD
  end

  if [ $GIT ]
    echo -sn (set_color normal) (fish_git_prompt)
  end

  echo -ns (set_color -o $target_color) ' -> '
  set_color normal
end

function tmux --description 'tmux multiplexer'
  command tmux -f $HOME/.config/tmux/.tmux.conf $argv
end

function vmux --description 'tmux launch/join session vir'
  command tmux -f $HOME/.config/tmux/.tmux.conf attach -t vir $argv || tmux -f $HOME/.config/tmux/.tmux.conf new -s vir $argv
end

function wmux --description 'tmux launch/attach session vir'
  set -l sess_name (echo "vir_$(random 0 100)")
  command tmux -f $HOME/.config/tmux/.tmux.conf new-session -t vir -s $sess_name $argv
end

function tree --description 'tree'
    command tree -C -I 'node_modules|venv|.git|__pycache__' $argv
end
# }}}

function download_configs
  mkdir -p $HOME/workspace/
  cd $HOME/workspace/

  if not [ -d configs ]
    # only clone: dont install yet
    git clone https://www.github.com/ViRu-ThE-ViRuS/configs.git
  else
    # clone repo only when not present already
    echo "repo. already present $HOME/workspace/configs/"
  end

  cd $HOME
end

# {{{ dev-env api
function dvim --description 'launch dev neovim'
  if command -sq 'docker'
    command nvim --remote-ui --server localhost:5757 $argv
    return
  end

  command nvim $argv
end

function dev --description 'launch dev shell' -a name
  set -l target dev-(basename (pwd))

  if test -n "$name"
    set target $name
  end

  if not command -sq 'docker'
    echo '[!] need to install docker to support dev envs'
    return
  end

  docker exec -it $target fish
  if test $status -ne 0
    echo "[!] [$target] env not running"
  end
end

function configure_dev --description 'configure dev server and environment'
  if not command -sq 'docker'
    echo '[!] check docker installation'
    return -1
  end

  if not [ -d "$HOME/workspace/configs" ]
    echo '[!] check configs repository'
    return -1
  end

  set -l pwd (pwd)
  echo '[@] building dev image'

  cd $HOME/workspace/configs/
  docker build --network=host --ssh=default -t dev -f Dockerfile .
  cd $pwd

  echo '[@] dev image built and environment configured'
  return 0
end

function start_dev --description 'start dev server' -a name
  set -l target dev-(basename (pwd))

  if test -n "$name"
    set target $name
  end

  set -l current (docker ps -q -f name=$target)
  if test -n "$current"
    echo "[@] [$target] dev server is already running"
    return
  end

  if not configure_dev
    echo "[!] could not configure dev env"
    return
  end

  # run container of needed and mount (pwd) as working dir
  docker run --network=host --hostname=dev --name=$target                  \
         --mount type=bind,source=$SSH_AUTH_SOCK,target=/ssh-agent         \
         --mount type=bind,source=(pwd),target=/workspace/(basename (pwd)) \
         -d --rm -it $target

  echo "[@] [$target] dev server has been started"
end

function stop_dev --description 'stop dev server' -a name
  set -l target dev-(basename (pwd))
  set -l msg_head "[$target]"

  if test -n "$name"
    set target $name
    set msg_head "[$target]"
  end

  set -l current (docker ps -a -q -f name=$target)
  if test -z "$current"
    echo "[@] [$target] dev server is already stopped"
    return
  end

  docker stop $target
  echo "[@] $msg_head dev server has been stopped"
end
# }}}

function computelab_nodes --description 'get nodes allocated to user viraatc on computelab'
  ssh computelab 'squeue -u viraatc -h' | awk '{print $NF}'
end

function last_history_item
  echo $history[1]
end
abbr -a !! --position anywhere --function last_history_item

# Added by Windsurf
fish_add_path /Users/viraatc/.codeium/windsurf/bin
