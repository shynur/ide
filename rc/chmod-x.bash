#! /bin/bash

function chmod-x {
    local exe=$1
    local exe_path=`which $exe`
    if [ $exe_path ]; then
        chmod -x $exe_path
    else
        echo "$exe is not an executable located in disk or cannot be found in PATH" >&2
    fi
}

for exe in \
remove-shell apt-cdrom                                                        \
bashbug i386                                                                  \
mail{,q,x} mke2fs mkfs{,.{bfs,cramfs,ext{2,3,4},minix}} mkswap mount movemail \
poweroff                                                                      \
update-shells                                                                 \
; do
    chmod-x $exe
done
