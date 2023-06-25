FROM ubuntu:22.04 AS base
WORKDIR /root

ARG SSH_PRV_KEY
ARG SSH_PUB_KEY
ARG DEBIAN_FRONTEND=noninteractive

# install updates and utils
RUN	 apt update && apt upgrade -y                              \
  && apt install -y software-properties-common build-essential \
	&& apt install -y cmake autoconf automake                    \
	&& apt install -y curl wget tree htop watch sudo unzip

# install python
RUN apt install -y python3-pip && pip3 install virtualenv pynvim neovim ipython

# install tools
RUN	 add-apt-repository -y ppa:neovim-ppa/unstable  && apt install -y neovim \
  && add-apt-repository -y ppa:fish-shell/release-3 && apt install -y fish   \
	&& add-apt-repository -y ppa:git-core/ppa				  && apt install -y git    \
	&& apt install -y tmux ripgrep bat universal-ctags

# install node, npm
RUN	 curl -sL https://deb.nodesource.com/setup_18.x -o /tmp/nodesource_setup.sh \
  && bash /tmp/nodesource_setup.sh && apt install -y nodejs

FROM base as dev

# setup user
# RUN useradd --create-home --shell $(which fish) -g root -G sudo viraat && passwd -d viraat
# USER viraat
# WORKDIR /home/viraat
WORKDIR $HOME

# install fzf
RUN	 mkdir -p ~/.local/bin && cd ~/.local/bin                                                    \
  && wget https://github.com/junegunn/fzf/releases/download/0.42.0/fzf-0.42.0-linux_amd64.tar.gz \
  && tar -xf fzf-0.42.0-linux_amd64.tar.gz && rm -rf fzf-0.42.0-linux_amd64.tar.gz

# install config files
RUN	 git clone https://www.github.com/ViRu-ThE-ViRuS/configs.git && cd ~/configs   \
  && mkdir -p ~/.config/nvim && mkdir -p ~/.config/fish && mkdir -p ~/.config/tmux \
  && sh ./update_config.sh 2> /dev/null

# setup env
RUN	 mkdir -p ~/.ssh && chmod 0700 ~/.ssh/                  \
  && echo "$SSH_PRV_KEY" > ~/.ssh/id_rsa                    \
  && echo "$SSH_PUB_KEY" > ~/.ssh/id_rsa.pub                \
  && chmod 600 ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa.pub \
  && eval `(ssh-agent -s)` && ssh-add ~/.ssh/id_rsa         \
  && ssh-keyscan github.com > ~/.ssh/known_hosts            \
  && git config --global --add safe.directory /

# initialize neovim plugins
RUN	nvim --headless "Lazy! sync" +qa

CMD ["fish"]

# docker build -t dev --build-arg SSH_PRV_KEY="$(cat ~/.ssh/id_rsa)" --build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" -f Dockerfile .
# docker run --hostname dev -it dev
# docker run --name=dev-box --hostname=dev --net host --tty --init --interactive --detach --add-host dev-box:127.0.0.1 --entrypoint=fish dev
# docker exec -it dev-box fish

# DOCKER_BUILDKIT=1 docker build -t tensorrt_llm-dev --build-arg SSH_PRV_KEY="$(cat ~/.ssh/id_rsa)" --build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" --network=host -f docker/Dockerfile.custom .
# docker run --gpus all --rm -it -v (pwd):/code/tensorrt_llm --hostname=dev --network=host -w /code/tensorrt_llm tensorrt_llm-dev fish
