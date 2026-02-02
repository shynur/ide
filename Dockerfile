FROM ubuntu AS gcc-builder
RUN apt update
ENV DEBIAN_FRONTEND=noninteractive
#RUN apt install -y tzdata
#RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN apt install -y g++ make wget
RUN apt install -y bzip2

COPY make-gcc/src/ /opt/make-gcc/src/
WORKDIR /opt/make-gcc/src
RUN ./contrib/download_prerequisites
#------
COPY make-gcc/build/ /opt/make-gcc/build/
WORKDIR /opt/make-gcc/build
RUN ./my-configure.bash --prefix=/opt/gcc
RUN make -j`nproc`
