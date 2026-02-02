#!/bin/bash

CFLAGS='-g0 -O3'

CFLAGS=$CFLAGS CXXFLAGS=$CFLAGS ../src/configure \
--program-suffix=-16 \
--enable-shared \
--disable-host-shared \
--enable-versioned-jit \
--disable-host-pie \
--disable-libgdiagnostics \
--enable-gcov \
--enable-__cxa_atexit \
--enable-gnu-indirect-function \
--disable-bootstrap \
--enable-languages=c++ \
--enable-libsanitizer \
--enable-libgomp \
--disable-default-pie \
--disable-default-ssp \
--disable-checking \
--disable-coverage \
--disable-gather-detailed-mem-stats \
--disable-nls \
--disable-decimal-float \
--disable-fixed-point \
--enable-linker-build-id \
--enable-lto \
--disable-cet \
--enable-x86-64-mfentry \
--disable-multilib \
"$@"
