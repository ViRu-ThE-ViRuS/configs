FROM ubuntu:22.04 as dev-configs
WORKDIR /root

# ENV SSH_AUTH_SOCK=/ssh-agent
ENV NVIM_PORT=5757
ENV DEBIAN_FRONTEND=noninteractive

# install updates and utils
RUN  apt update && apt upgrade -y                              \
  && apt install -y software-properties-common build-essential \
  && apt install -y cmake autoconf automake                    \
  && apt install -y curl wget tree htop watch sudo unzip file

# install python
RUN apt install -y python3-pip && pip3 install virtualenv pynvim neovim ipython

# install node, npm
RUN  curl -sL https://deb.nodesource.com/setup_18.x -o /tmp/nodesource_setup.sh \
  && bash /tmp/nodesource_setup.sh && apt install -y nodejs

# install tools
RUN  add-apt-repository -y ppa:neovim-ppa/unstable  && apt install -y neovim \
  && add-apt-repository -y ppa:fish-shell/release-3 && apt install -y fish   \
  && add-apt-repository -y ppa:git-core/ppa         && apt install -y git    \
  && apt install -y tmux ripgrep bat universal-ctags

# setup user
# RUN useradd --create-home --shell $(which fish) -g root -G sudo viraat && passwd -d viraat
# USER viraat
# WORKDIR /home/viraat
WORKDIR $HOME/

# install fzf
RUN  mkdir -p $HOME/.local/bin && cd $HOME/.local/bin                                            \
  && wget https://github.com/junegunn/fzf/releases/download/0.42.0/fzf-0.42.0-linux_amd64.tar.gz \
  && tar -xf fzf-0.42.0-linux_amd64.tar.gz && rm -rf fzf-0.42.0-linux_amd64.tar.gz

# install config files
RUN  git config --global --add safe.directory /                                                      \
  && git clone https://www.github.com/ViRu-ThE-ViRuS/configs.git $HOME/_configs && cd $HOME/_configs \
  && mkdir -p $HOME/.config/nvim && mkdir -p $HOME/.config/fish && mkdir -p $HOME/.config/tmux       \
  && sh ./update_config.sh 2> /dev/null

# initialize neovim
RUN --mount=type=ssh mkdir -p $HOME/.ssh/                                                                \
  && ssh-keyscan github.com >> $HOME/.ssh/known_hosts                                                    \
  && nvim --headless 'Lazy! sync' +qa                                                                    \
  && touch test.txt && nvim +TSUpdateSync '+MasonInstall clangd pyright' +qa test.txt && rm -rf test.txt \
  && chsh -s /usr/bin/fish

WORKDIR $HOME/workspace

CMD fish -c "echo 'starting neovim server on port: $NVIM_PORT' ; while true ; nvim --headless --listen localhost:$NVIM_PORT ; end"

# ---:notes:---
# server_mode       [ neovim-remote ]
# -----------
# NOTE(vir): ssh does not seem to work,
# so need neovim setup within CMD for server config
#
# docker compose build
# docker compose up -d
#
# docker build --network=host --ssh=default -t dev -f Dockerfile .
# docker run --network=host --hostname=dev --name=dev                      \
#        --mount type=bind,source=$SSH_AUTH_SOCK,target=/ssh-agent         \
#        --mount type=bind,source=(pwd),target=/workspace/(basename (pwd)) \
#        --rm -it dev
#
# instance_mode     [ fish-shell ]
# -------------
# docker build --network=host --ssh=default -t dev -f Dockerfile .
# docker run --network=host --hostname=dev --name=dev                      \
#        --mount type=bind,source=$SSH_AUTH_SOCK,target=/ssh-agent         \
#        --mount type=bind,source=(pwd),target=/workspace/(basename (pwd)) \
#        --rm -it dev

