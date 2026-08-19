#!/bin/bash -l
PS1=force_eval . ~/.bashrc

chmod a-x -- "$0"

MY_MIHOMO_PORT=7890
if my-mihomo.bash up &>/dev/null; then
    echo "export http_proxy=http://127.0.0.1:$MY_MIHOMO_PORT https_proxy=http://127.0.0.1:$MY_MIHOMO_PORT all_proxy=socks5h://127.0.0.1:$MY_MIHOMO_PORT" >>/etc/profile
    MY_MIHOMO_UP=1
fi

apt install -y sshpass gh {un,}zip zstd xz-utils jq rsync ripgrep file git-lfs xxd &>/dev/null &

git config --global credential.helper "cache --timeout=$[2**31-1]"
echo >>~/.git-credentials
while IFS= read -r url; do
    if ! [ "$url" ]; then
        continue
    fi
    printf 'url=%s\n\n' "$url" | git credential approve
done <~/.git-credentials

(
    if [ $MY_MIHOMO_UP ]; then
        export http_proxy=http://127.0.0.1:$MY_MIHOMO_PORT https_proxy=http://127.0.0.1:$MY_MIHOMO_PORT all_proxy=socks5h://127.0.0.1:$MY_MIHOMO_PORT
    fi
    kimi --auto web --host --allow-remote-terminals --dangerous-bypass-auth --no-open &
)

(
    if [ $MY_MIHOMO_UP ]; then
        export http_proxy=http://127.0.0.1:$MY_MIHOMO_PORT https_proxy=http://127.0.0.1:$MY_MIHOMO_PORT all_proxy=socks5h://127.0.0.1:$MY_MIHOMO_PORT
    fi
    code --no-sandbox --locale zh-CN serve-web --host 0.0.0.0 --without-connection-token --accept-server-license-terms --disable-telemetry --port 8000 &
)

/usr/sbin/sshd -D

wait
