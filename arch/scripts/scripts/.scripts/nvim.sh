#!/usr/bin/env bash

# Script used to launch neovim from outside terminal. This will ensure that nodejs
# installed with nvim is properly referenced so tooling continues to work
source "$HOME/.nvm/nvm.sh"
exec nvim "$@"
