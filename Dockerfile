FROM ubuntu AS base
SHELL ["/bin/bash", "-c"]
RUN apt update &>/dev/null
ENV DEBIAN_FRONTEND=noninteractive

# --------------------------------

FROM base AS wget-user
RUN apt install -y wget &>/dev/null

# --------------------------------

FROM wget-user AS golang-builder
RUN apt install -y git &>/dev/null
WORKDIR /tmp
RUN GO_VERSION=`git ls-remote --tags --refs https://github.com/golang/go.git 'refs/tags/go*' | sed -E s/'^[[:xdigit:]]+[[:space:]]+refs\/tags\/go'// | egrep '^[0-9]+(\.[0-9]+)*$' | sort -V -r | head -1`; wget https://golang.google.cn/dl/go$GO_VERSION.`sed s/'^linux-gnu$'/linux/ <<<$OSTYPE`-`sed -e s/'^x86_64$'/amd64/ -e s/'^aarch64$'/arm64/ <<<$HOSTTYPE`.tar.gz &>/dev/null
RUN tar -C /usr/local -xzf go*.*-*.tar.gz

# --------------------------------

FROM base AS cmake-builder
RUN apt install -y wget git &>/dev/null
WORKDIR /tmp
RUN CMAKE_VERSION=`git ls-remote --tags --refs https://github.com/Kitware/CMake.git 'refs/tags/v*' | sed -E s/'^[[:xdigit:]]+[[:space:]]+refs\/tags\/v'// | egrep '^[0-9]+(\.[0-9]+)*$' | sort -V -r | head -1`; wget -q https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-$HOSTTYPE.sh
RUN mkdir -p /opt/cmake; bash ./cmake-*-$HOSTTYPE.sh --skip-license --prefix=/opt/cmake --exclude-subdir

# --------------------------------

FROM base AS gcc-builder
RUN apt install -y g++ wget bzip2 file bison make flex libfl-dev &>/dev/null

COPY make-gcc/src/ /tmp/make-gcc/src/
WORKDIR /tmp/make-gcc/src
RUN ./contrib/download_prerequisites

COPY make-gcc/build/ /tmp/make-gcc/build/
WORKDIR /tmp/make-gcc/build
RUN ./my-configure.bash --prefix=/opt/gcc >/dev/null
RUN make -j`nproc` >/dev/null
RUN make -j$[`nproc`+1] install >/dev/null
WORKDIR /opt/gcc/bin
RUN if ! [ -x gcc ]; then ln -s `ls | grep '^gcc' | head -1` gcc; fi
RUN if ! [ -x g++ ]; then ln -s `ls | grep '^g++' | head -1` g++; fi
RUN ln -s gcc cc
RUN ln -s g++ c++

# --------------------------------

FROM base AS cmake-user

RUN apt install -y libc6-dev binutils make &>/dev/null

COPY --from=cmake-builder /opt/cmake/ /opt/cmake/
ENV PATH="$PATH:/opt/cmake/bin"

COPY --from=gcc-builder   /opt/gcc/   /opt/gcc/
ENV CC=/opt/gcc/bin/gcc CXX=/opt/gcc/bin/g++

# --------------------------------

#FROM cmake-user AS <SDK>-builder
#ARG USER=
#ARG REPO=
#ARG TAG=
#RUN apt install -y git
#WORKDIR /tmp
#RUN git clone --single-branch --branch=${TAG} --depth=1 https://github.com/${USER}/${REPO}.git
#RUN cmake -S ${REPO} -B build -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Debug
#RUN cmake --build build -j `nproc`
#RUN cmake --install build --prefix /opt/${REPO}

# --------------------------------

FROM base AS dotemacs-builder

RUN apt install -y emacs-nox &>/dev/null
RUN mkdir -p ~/.config/emacs
RUN touch ~/.config/emacs/init.el

RUN emacs -x <(echo "(package-install 'dockerfile-mode)") &>/dev/null
RUN emacs -x <(echo "(package-install 'csv-mode)")        &>/dev/null
RUN emacs -x <(echo "(package-install 'git-modes)")       &>/dev/null
RUN emacs -x <(echo "(package-install 'go-mode)")         &>/dev/null
RUN emacs -x <(echo "(package-install 'json-mode)")       &>/dev/null
RUN emacs -x <(echo "(package-install 'markdown-mode)")   &>/dev/null
RUN emacs -x <(echo "(package-install 'nginx-mode)")      &>/dev/null
RUN emacs -x <(echo "(package-install 'rainbow-mode)")    &>/dev/null
RUN emacs -x <(echo "(package-install 'sed-mode)")        &>/dev/null
RUN emacs -x <(echo "(package-install 'typescript-mode)") &>/dev/null
RUN emacs -x <(echo "(package-install 'web-mode)")        &>/dev/null
RUN emacs -x <(echo "(package-install 'yaml-mode)")       &>/dev/null
RUN emacs -x <(echo "(require 'package) (add-to-list 'package-archives '(\"melpa-stable\" . \"https://stable.melpa.org/packages/\") t) (package-initialize) (package-refresh-contents) (package-install 'cmake-mode)") &>/dev/null

# --------------------------------

FROM base AS homedir-builder

COPY HOME/.config/      /root/.config/
COPY HOME/.bash_profile /root/
COPY HOME/.bashrc       /root/
COPY HOME/.inputrc      /root/
COPY HOME/.conan2/      /root/.conan2/
COPY HOME/.codex/       /root/.codex/
COPY HOME/.local/bin/   /root/.local/bin/

COPY --from=dotemacs-builder /root/.config/emacs/ /root/.config/emacs/

RUN echo '. ~/.local/bin/alias-with-secrets.bash /etc/shynur-ide/ai-api-keys.json' >>/root/.bashrc

# ---------------------------------

FROM base AS etcdir-builder
RUN apt install -y git &>/dev/null
WORKDIR /tmp

RUN mkdir -p /etc/bash_completion.d
RUN git clone --depth=1 https://gitlab.com/akim.saidani/conan-bashcompletion.git
RUN mv conan-bashcompletion/conan-completion /etc/bash_completion.d

# --------------------------------

FROM base AS ssh-server

RUN apt install -y openssh-server bash-completion &>/dev/null

EXPOSE 22
RUN echo >>/etc/ssh/sshd_config 'PermitRootLogin yes'
RUN echo >>/etc/ssh/sshd_config 'PasswordAuthentication yes'
RUN echo >>/etc/ssh/sshd_config 'Banner none'

RUN sed -i '/pam_motd\.so/ s/^/#/' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

RUN echo 'root: ' | chpasswd

COPY --from=etcdir-builder /etc/bash_completion.d/ /etc/bash_completion.d/
COPY --from=homedir-builder /root/ /root/

# --------------------------------

FROM ssh-server AS dev

# 安装 python, venv, pipx
RUN apt install -y tzdata &>/dev/null
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN apt install -y python3 python3-venv pipx &>/dev/null

# 安装 Emacs
RUN apt install -y emacs-nox &>/dev/null

# 安装 常用工具
RUN apt install -y git iproute2 sudo make htop wget curl psmisc tree fzf bat curl &>/dev/null

# 安装 CMake
COPY --from=cmake-builder /opt/cmake/ /opt/cmake/
RUN echo 'export PATH+=:/opt/cmake/bin' >>/etc/profile
ENV PATH="$PATH:/opt/cmake/bin"

# 安装 GCC
COPY --from=gcc-builder   /opt/gcc/   /opt/gcc/
RUN echo 'export PATH+=:/opt/gcc/bin' >>/etc/profile
ENV PATH="$PATH:/opt/gcc/bin"
RUN echo 'export CC=/opt/gcc/bin/gcc CXX=/opt/gcc/bin/g++' >>/etc/profile

# 安装 JFrog Conan
RUN PATH+=:~/.local/bin pipx install conan
RUN PATH+=:~/.local/bin conan profile detect --force
RUN sed -i s/^build_type=Release\$/build_type=Debug/ ~/.conan2/profiles/default

# 安装 Node.js
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
RUN . ~/.nvm/nvm.sh; nvm install 24
RUN . ~/.nvm/nvm.sh; npm install -g @anthropic-ai/claude-code @openai/codex @google/gemini-cli @github/copilot

# 安装 Go
COPY --from=golang-builder /usr/local/go/ /usr/local/go/

WORKDIR /root/
CMD ["/bin/bash", "-l"]
