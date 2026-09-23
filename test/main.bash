#!/bin/bash
set -e
cd `dirname $0`


. ~/.cargo/env
. ~/.nvm/nvm.sh


cmake --version
#cargo version
conan -v
emacs -version
g++ -v
go version
node -v
python3 --version
mihomo --help
code --version
#claude -v
#codex --version
#copilot -v
#gemini -v
kimi --version
