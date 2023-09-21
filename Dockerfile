FROM ubuntu:22.04 as dev-configs
WORKDIR /root

# ENV SSH_AUTH_SOCK=/ssh-agent
ENV NVIM_PORT=5757
ENV DEBIAN_FRONTEND=noninteractive

# install updates and utils
RUN apt update; apt upgrade -y;                                                                                                  \
    apt install -y software-properties-common build-essential cmake autoconf automake curl wget tree htop watch sudo unzip file;

# install python
RUN apt install -y python3-pip; pip3 install virtualenv pynvim neovim ipython

# install nodejs
RUN mkdir -p /etc/apt/keyrings; curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg;                         \
    NODE_MAJOR=18; echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list; \
    apt-get update; apt-get install -y nodejs

# install tools
RUN add-apt-repository -y ppa:neovim-ppa/unstable;   \
    add-apt-repository -y ppa:fish-shell/release-3;  \
    add-apt-repository -y ppa:git-core/ppa;          \
    apt install -y neovim fish git tmux ripgrep bat;

# setup user
# RUN useradd --create-home --shell $(which fish) -g root -G sudo viraat && passwd -d viraat
# USER viraat
WORKDIR $HOME/

# install binaries
RUN mkdir -p $HOME/.local/bin;                                                                                                                                                                                   \
    wget https://github.com/junegunn/fzf/releases/download/0.42.0/fzf-0.42.0-linux_amd64.tar.gz -O $HOME/.local/bin/fzf.tar.gz;                                                                                  \
    tar -xf $HOME/.local/bin/fzf.tar.gz -C $HOME/.local/bin/;                                                                                                                                                    \
    wget https://github.com/universal-ctags/ctags-nightly-build/releases/download/2023.09.20%2Bdedfed1a22ab542be257fd14362fcc919d4140dc/uctags-2023.09.20-linux-x86_64.tar.xz -O $HOME/.local/bin/uctags.tar.xz; \
    tar -xf $HOME/.local/bin/uctags.tar.xz -C $HOME/.local/bin/; mv $HOME/.local/bin/uctags-2023.09.20-linux-x86_64/bin/ctags $HOME/.local/bin/;                                                                 \
    rm -rf ~/.local/bin/*.tar.*;


# install config files
RUN git clone https://www.github.com/ViRu-ThE-ViRuS/configs.git $HOME/configs;            \
    mkdir -p $HOME/.config/nvim $HOME/.config/nvim $HOME/.config/fish $HOME/.config/tmux; \
    cd $HOME/configs && sh ./update_config.sh 2> /dev/null;

# initialize neovim
RUN nvim --headless 'Lazy! sync' +qa;                                                               \
    touch test.txt; nvim +TSUpdateSync '+MasonInstall clangd pyright' +qa test.txt; rm -rf test.txt \
    chsh -s $(which fish)

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

