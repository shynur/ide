FROM ubuntu AS base
RUN apt update
ENV DEBIAN_FRONTEND=noninteractive

# --------------------------------

FROM base AS cmake-builder
RUN apt install -y wget
WORKDIR /tmp
RUN bash -c 'CMAKE_VERSION=4.2.3; wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-$HOSTTYPE.sh'
RUN mkdir -p /opt/cmake; bash -c 'bash ./cmake-*-$HOSTTYPE.sh --skip-license --prefix=/opt/cmake --exclude-subdir'

# --------------------------------

FROM base AS gcc-builder
RUN apt install -y g++ wget
RUN apt install -y bzip2
RUN apt install -y file

COPY make-gcc/src/ /tmp/make-gcc/src/
WORKDIR /tmp/make-gcc/src
RUN ./contrib/download_prerequisites

COPY make-gcc/build/ /tmp/make-gcc/build/
WORKDIR /tmp/make-gcc/build
RUN apt install -y flex libfl-dev
RUN ./my-configure.bash --prefix=/opt/gcc
RUN apt install -y bison
RUN apt install -y make
RUN make -j`nproc`
RUN bash -c 'make -j$[`nproc`+1] install'
WORKDIR /opt/gcc/bin
RUN bash -c "[ -x gcc ] || ln -s `ls | grep '^gcc' | head -1` gcc"
RUN bash -c "[ -x g++ ] || ln -s `ls | grep '^g++' | head -1` g++"

# --------------------------------

FROM base AS cmake-user

RUN apt install -y libc6-dev binutils make

COPY --from=cmake-builder /opt/cmake/ /opt/cmake/
ENV PATH="$PATH:/opt/cmake/bin"

COPY --from=gcc-builder   /opt/gcc/   /opt/gcc/
ENV CC=/opt/gcc/bin/gcc CXX=/opt/gcc/bin/g++

# --------------------------------

#FROM cmake-user AS <SDK>-builder
#RUN apt install -y git
#WORKDIR /tmp
#RUN git clone --single-branch --branch=<TAG> --depth=1 https://github.com/<USERNAME>/<REPO>.git
#RUN bash -c 'cmake -S <REPO> -B build -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Debug'
#RUN cmake --build build -j `nproc`
#RUN cmake --install build --prefix /opt/<REPO>

# --------------------------------

FROM base AS dotemacs-builder

RUN apt install -y emacs-nox
RUN bash -c 'mkdir -p ~/.config/emacs'
RUN bash -c 'touch ~/.config/emacs/init.el'

RUN bash -c "emacs -x <(echo \"(package-install 'dockerfile-mode)\")"
RUN bash -c "emacs -x <(echo \"(package-install 'csv-mode)\")"
RUN bash -c "emacs -x <(echo \"(package-install 'git-modes)\")"
RUN bash -c "emacs -x <(echo \"(package-install 'go-mode)\")"
RUN bash -c "emacs -x <(echo \"(package-install 'json-mode)\")"
RUN bash -c "emacs -x <(echo \"(package-install 'markdown-mode)\")"
RUN bash -c "emacs -x <(echo \"(package-install 'nginx-mode)\")"
RUN bash -c "emacs -x <(echo \"(package-install 'rainbow-mode)\")"
RUN bash -c "emacs -x <(echo \"(package-install 'sed-mode)\")"
RUN bash -c "emacs -x <(echo \"(package-install 'typescript-mode)\")"
RUN bash -c "emacs -x <(echo \"(package-install 'web-mode)\")"
RUN bash -c "emacs -x <(echo \"(package-install 'yaml-mode)\")"
RUN bash -c "emacs -x <(echo \"(require 'package) (add-to-list 'package-archives '(\\\"melpa-stable\\\" . \\\"https://stable.melpa.org/packages/\\\") t) (package-initialize) (package-refresh-contents) (package-install 'cmake-mode)\")"

# --------------------------------

FROM base AS homedir-builder

COPY HOME/.config/      /root/.config/
COPY HOME/.bash_profile /root/
COPY HOME/.bashrc       /root/
COPY HOME/.inputrc      /root/
COPY HOME/.conan2/      /root/.conan2/

COPY --from=dotemacs-builder /root/.config/emacs/ /root/.config/emacs/

# --------------------------------

FROM base AS ssh-server

RUN apt install -y openssh-server

EXPOSE 22
RUN echo >>/etc/ssh/sshd_config 'PermitRootLogin yes'
RUN echo >>/etc/ssh/sshd_config 'PasswordAuthentication yes'
RUN echo >>/etc/ssh/sshd_config 'Banner none'

RUN sed -i '/pam_motd\.so/ s/^/#/' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

RUN echo 'root: ' | chpasswd

# 都 SSH 登录了, 可不得支持一下补全吗.
RUN apt install -y bash-completion

# 安装 ~/
COPY --from=homedir-builder /root/ /root/

# --------------------------------

FROM ssh-server AS dev

# 安装 python, venv, pipx
RUN apt install -y tzdata
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN apt install -y python3 python3-venv pipx

# 安装 Emacs
RUN apt install -y emacs-nox

# 安装 常用工具
RUN apt install -y git iproute2 sudo make htop wget curl psmisc tree fzf bat

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
RUN bash -c 'PATH+=:~/.local/bin pipx install conan'
RUN bash -c 'PATH+=:~/.local/bin conan profile detect --force'
RUN bash -c 'sed -i "s/^build_type=Release\$/build_type=Debug/" ~/.conan2/profiles/default'

WORKDIR /root/
CMD ["/bin/bash", "-l"]

# ---------------------------------

FROM dev AS rbk-cacher
WORKDIR /tmp/huaweicloudsdkall

RUN python3 -m venv .venv
RUN bash -c '. .venv/bin/activate; pip install huaweicloudsdkall'

# .................................

FROM dev AS rbk-dev

COPY --from=rbk-cacher /root/.cache/pip/ /root/.cache/pip/

