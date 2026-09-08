#!/usr/bin/env bash

# Script used to launch neovim from outside terminal. This will ensure that nodejs
# installed with nvim is properly referenced so tooling continues to work
export NVM_DIR="$HOME/.nvm"
NODE_BIN=$(ls -d "$NVM_DIR"/versions/node/*/bin 2>/dev/null | sort -V | tail -1)
export PATH="$NODE_BIN:$PATH"
exec nvim "$@"
