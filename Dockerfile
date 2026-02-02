FROM ubuntu AS base
RUN apt update
ENV DEBIAN_FRONTEND=noninteractive



FROM base AS cmake-builder
RUN apt install -y wget
WORKDIR /tmp
RUN wget https://github.com/Kitware/CMake/releases/download/v4.2.3/cmake-4.2.3-linux-$HOSTTYPE.sh
RUN bash ./cmake-*-$HOSTTYPE.sh --skip-license --prefix=/opt/cmake --exclude-subdir



FROM base AS conan-builder
RUN apt install -y tzdata
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN apt install -y python3 python3-pip



FROM base AS gcc-builder
RUN apt install -y g++ wget
RUN apt install -y bzip2

COPY make-gcc/src/ /tmp/make-gcc/src/
WORKDIR /tmp/make-gcc/src
RUN ./contrib/download_prerequisites
#------
COPY make-gcc/build/ /tmp/make-gcc/build/
WORKDIR /tmp/make-gcc/build
RUN apt install -y flex libfl-dev
RUN ./my-configure.bash --prefix=/opt/gcc
RUN apt install -y bison
RUN apt install -y make
RUN make -j`nproc`
