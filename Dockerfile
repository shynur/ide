FROM ubuntu AS base
RUN apt update
ENV DEBIAN_FRONTEND=noninteractive




FROM base AS cmake-builder
RUN apt install -y wget
WORKDIR /tmp
RUN bash -c 'wget https://github.com/Kitware/CMake/releases/download/v4.2.3/cmake-4.2.3-linux-$HOSTTYPE.sh'
RUN bash -c 'bash ./cmake-*-$HOSTTYPE.sh --skip-license --prefix=/opt/cmake --exclude-subdir'




FROM base AS conan-builder
#RUN apt install -y tzdata
#RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#RUN dpkg-reconfigure --frontend noninteractive tzdata
#RUN apt install -y python3
RUN apt install -y wget
WORKDIR /tmp
RUN bash -c 'wget https://github.com/conan-io/conan/releases/download/2.25.1/conan-2.25.1-linux-$HOSTTYPE.tgz'
RUN bash -c 'mkdir -p /opt/conan; tar -xf ./conan-*-$HOSTTYPE.tgz -C /opt/conan'




FROM base AS gcc-builder
RUN apt install -y g++ wget
RUN apt install -y bzip2

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




FROM base AS dev
COPY --from=cmake-builder /opt/ /opt/
COPY --from=conan-builder /opt/ /opt/
COPY --from=gcc-builder /opt/ /opt/
ENV PATH="/opt/cmake/bin:/opt/conan/bin:/opt/gcc/bin:${PATH}"
