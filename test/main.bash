#!/bin/bash
set -e
cd `dirname $0`


#. ~/.cargo/env
#cargo version

. ~/.nvm/nvm.sh
node -v
kimi --version
#claude -v
#codex --version
#copilot -v
#gemini -v

cmake --version
conan -v
emacs -version
g++ -v
go version
python3 --version
mihomo --help
code --version
