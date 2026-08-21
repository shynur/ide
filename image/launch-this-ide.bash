#!/bin/bash -l
chmod a-x -- "$0"

while getopts ':d' opt; do
    case $opt in
        d) SHYNUR_IDE_SSH_SERVER_MODE=1 ;;
    esac
done

PS1=force_eval . ~/.bashrc

MY_MIHOMO_PORT=7890
if my-mihomo.bash up &>/dev/null; then
    MY_MIHOMO_UP=1
    MY_MIHOMO_HTTP_PROXY=http://127.0.0.1:$MY_MIHOMO_PORT MY_MIHOMO_HTTPS_PROXY=http://127.0.0.1:$MY_MIHOMO_PORT MY_MIHOMO_ALL_PROXY=socks5h://127.0.0.1:$MY_MIHOMO_PORT
    {
        echo "export http_proxy=$MY_MIHOMO_HTTP_PROXY https_proxy=$MY_MIHOMO_HTTPS_PROXY all_proxy=$MY_MIHOMO_ALL_PROXY"
        echo 'export HTTP_PROXY=$http_proxy HTTPS_PROXY=$https_proxy ALL_PROXY=$all_proxy'
    } >>/etc/profile
fi

apt install -y sshpass gh {un,}zip zstd xz-utils jq rsync ripgrep file git-lfs xxd >/dev/null &

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
        export http_proxy=$MY_MIHOMO_HTTP_PROXY https_proxy=$MY_MIHOMO_HTTPS_PROXY all_proxy=$MY_MIHOMO_ALL_PROXY
        export HTTP_PROXY=$http_proxy           HTTPS_PROXY=$https_proxy           ALL_PROXY=$all_proxy
    fi
    kimi --auto web --host --allow-remote-terminals --dangerous-bypass-auth --no-open --port 58627 &
)

(
    if [ $MY_MIHOMO_UP ]; then
        export http_proxy=$MY_MIHOMO_HTTP_PROXY https_proxy=$MY_MIHOMO_HTTPS_PROXY all_proxy=$MY_MIHOMO_ALL_PROXY
        export HTTP_PROXY=$http_proxy           HTTPS_PROXY=$https_proxy           ALL_PROXY=$all_proxy
    fi
    code --locale zh-CN serve-web --host 0.0.0.0 --without-connection-token --accept-server-license-terms --disable-telemetry --port 8000 &
)

if [ $SHYNUR_IDE_SSH_SERVER_MODE ]; then
    /usr/sbin/sshd -D
else
    cd
    bash -l
fi
