FROM ubuntu AS gcc-builder

RUN apt update
ENV DEBIAN_FRONTEND=noninteractive
#RUN apt install -y tzdata
#RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN apt install -y g++ make wget

COPY make-gcc/ /opt/make-gcc/
WORKDIR /opt/make-gcc/src
RUN ./contrib/download_prerequisites
WORKDIR /opt/make-gcc/build
RUN ../src/my-configure.bash --prefix=/opt/gcc
