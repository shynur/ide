#!/bin/bash

../src/configure \
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

"$@"
