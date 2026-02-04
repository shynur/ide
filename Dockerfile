FROM ubuntu AS base
RUN apt update
ENV DEBIAN_FRONTEND=noninteractive




FROM base AS cmake-builder
RUN apt install -y wget
WORKDIR /tmp
RUN bash -c 'wget https://github.com/Kitware/CMake/releases/download/v4.2.3/cmake-4.2.3-linux-$HOSTTYPE.sh'
RUN mkdir -p /opt/cmake; bash -c 'bash ./cmake-*-$HOSTTYPE.sh --skip-license --prefix=/opt/cmake --exclude-subdir'




FROM base AS conan-builder
RUN apt install -y wget
WORKDIR /tmp
RUN bash -c 'wget https://github.com/conan-io/conan/releases/download/2.25.1/conan-2.25.1-linux-$HOSTTYPE.tgz'
RUN mkdir -p /opt/conan; bash -c 'tar -xf ./conan-*-$HOSTTYPE.tgz -C /opt/conan'




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




FROM base AS spdlog-builder
RUN apt install -y git
WORKDIR /tmp
RUN git clone --single-branch --branch=v1.17.0 --depth=1 https://github.com/gabime/spdlog.git
RUN bash -c 'cmake -S spdlog -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_{C,CXX}_FLAGS_RELEASE="-DNDEBUG -g0 -O0 -w"'
RUN cmake --build build
RUN cmake --install build --prefix /opt/spdlog




FROM base AS ssh-server
RUN apt install -y openssh-server
EXPOSE 22
RUN echo >>/etc/ssh/sshd_config 'PermitRootLogin yes'
RUN echo >>/etc/ssh/sshd_config 'PasswordAuthentication yes'
RUN echo >>/etc/ssh/sshd_config 'Banner none'
RUN sed -i '/pam_motd\.so/ s/^/#/' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd




FROM base AS dotemacs-builder
RUN apt install -y emacs-nox

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




FROM ssh-server AS dev

# 安装 python
RUN apt install -y tzdata
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN apt install -y python3 python3-venv

# 安装 emacs
RUN apt install -y emacs-nox

# 安装 常用工具
RUN apt install -y bash-completion git iproute2 sudo make htop wget curl psmisc tree fzf bat

COPY --from=cmake-builder /opt/cmake/ /opt/cmake/
RUN echo 'export PATH+=:/opt/cmake/bin' >>/etc/profile
ENV PATH="$PATH:/opt/cmake/bin"

COPY --from=conan-builder /opt/conan/ /opt/conan/
RUN echo 'export PATH+=:/opt/conan/bin' >>/etc/profile
ENV PATH="$PATH:/opt/conan/bin"

COPY --from=gcc-builder   /opt/gcc/   /opt/gcc/
RUN echo 'export PATH+=:/opt/gcc/bin' >>/etc/profile
ENV PATH="$PATH:/opt/gcc/bin"
RUN echo 'export CC=/opt/gcc/bin/gcc CXX=/opt/gcc/bin/g++' >>/etc/profile

COPY --from=dotemacs-builder /root/.emacs.d/ /root/.emacs.d/

# 一些必要的配置
RUN echo 'export LANG=en_US.UTF-8' >>/etc/profile
COPY HOME/.inputrc    /root/
#>>> bashrc
RUN echo '. ~/.shynur.bashrc' >>/root/.bashrc
COPY HOME/.bashrc     /root/.shynur.bashrc
#<<<
RUN echo 'root: ' | chpasswd

WORKDIR /root/
CMD ["/bin/bash", "-l"]










FROM base AS huaweicloudsdk-builder
RUN apt install -y git make
RUN apt install -y libcurl4-openssl-dev libboost-all-dev libssl-dev libcpprest-dev librttr-dev  # 我服了 huawei 这个逆天 README 里居然没提要安装 rttr
COPY --from=spdlog-builder /opt/spdlog/ /usr/local/

COPY --from=cmake-builder /opt/cmake/ /opt/cmake/
ENV PATH="$PATH:/opt/cmake/bin"
COPY --from=gcc-builder   /opt/gcc/   /opt/gcc/
ENV CC=/opt/gcc/bin/gcc CXX=/opt/gcc/bin/g++

WORKDIR /tmp
RUN git clone --single-branch --depth=1 https://github.com/huaweicloud/huaweicloud-sdk-cpp-v3.git
RUN bash -c 'echo >>huaweicloud-sdk-cpp-v3/CMakeLists.txt; for src in cce/src/v{3,5}; do echo "add_subdirectory($src)" >>huaweicloud-sdk-cpp-v3/CMakeLists.txt; done'
RUN bash -c 'cmake -S huaweicloud-sdk-cpp-v3 -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_{C,CXX}_FLAGS_RELEASE="-DNDEBUG -g0 -O0 -w"'
RUN cmake --build build -j `nproc`
RUN cmake --install build --prefix /opt/huaweicloud-sdk-cpp-v3




FROM dev AS rbk-dev
RUN apt install -y libcurl4-openssl-dev libboost-all-dev libssl-dev libcpprest-dev librttr-dev  # huaweicloudsdk 需要
COPY --from=spdlog-builder /opt/spdlog/ /opt/spdlog/
COPY --from=huaweicloudsdk-builder /opt/huaweicloud-sdk-cpp-v3/ /opt/huaweicloud-sdk-cpp-v3/
