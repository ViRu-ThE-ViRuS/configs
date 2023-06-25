FROM ubuntu:22.04
WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive

# install updates and utils
RUN  apt update && apt upgrade -y                              \
  && apt install -y software-properties-common build-essential \
  && apt install -y cmake autoconf automake                    \
  && apt install -y curl wget tree htop watch sudo unzip

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
WORKDIR $HOME

# install fzf
RUN  mkdir -p $HOME/.local/bin && cd $HOME/.local/bin                                            \
  && wget https://github.com/junegunn/fzf/releases/download/0.42.0/fzf-0.42.0-linux_amd64.tar.gz \
  && tar -xf fzf-0.42.0-linux_amd64.tar.gz && rm -rf fzf-0.42.0-linux_amd64.tar.gz

# install config files
RUN  git config --global --add safe.directory /                                                \
  && git clone https://www.github.com/ViRu-ThE-ViRuS/configs.git && cd $HOME/configs           \
  && mkdir -p $HOME/.config/nvim && mkdir -p $HOME/.config/fish && mkdir -p $HOME/.config/tmux \
  && sh ./update_config.sh 2> /dev/null

# initialize neovim
RUN --mount=type=ssh mkdir -p $HOME/.ssh/                                                                   \
    && ssh-keyscan github.com >> $HOME/.ssh/known_hosts                                                     \
    && nvim --headless "Lazy! sync" +qa                                                                     \
    && touch test.txt && nvim +TSUpdateSync "+MasonInstall clangd pyright " +qa test.txt && rm -rf test.txt

CMD ["fish"]

# ---:notes:---
# docker build --network=host --ssh=default -t dev -f Dockerfile .
# docker run --network=host --hostname=dev --name=dev --rm -it dev

