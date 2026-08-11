#!/bin/bash -l
PS1=force_eval . ~/.bashrc

chmod a-x -- "$0"

MY_MIHOMO_PORT=7890
if my-mihomo.bash up &>/dev/null; then
    echo "export http_proxy=http://127.0.0.1:$MY_MIHOMO_PORT https_proxy=http://127.0.0.1:$MY_MIHOMO_PORT all_proxy=socks5h://127.0.0.1:$MY_MIHOMO_PORT" >>/etc/profile
fi

apt install -y sshpass gh {un,}zip zstd xz-utils jq rsync ripgrep file &>/dev/null &

kimi --auto web --host --allow-remote-terminals --dangerous-bypass-auth --no-open &
/usr/sbin/sshd -D

wait
