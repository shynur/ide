#!/bin/bash
set -e
cd `dirname $0`


. ~/.cargo/env
. ~/.nvm/nvm.sh


cargo version
claude -v
cmake --version
codex --version
conan -v
copilot -v
emacs -version
g++ -v
gemini -v
go version
node -v
python3 --version
