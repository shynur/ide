#! /bin/bash
set -e

cd `dirname $0`

go version
g++ -v
cmake --version
conan -v
python3 --version
node -v
emacs -version
claude -v
codex --version
gemini -v
copilot -v
