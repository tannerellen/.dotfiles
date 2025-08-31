#!/bin/bash

# Current script directory
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Find the default release profile path
REAL_PROFILE_PATH=$(find ~/.mozilla/firefox -maxdepth 1 -name "*.default-release" -type d | head -n 1)

# Make sure folder exists
mkdir -p "$REAL_PROFILE_PATH"

if [ -z "$REAL_PROFILE_PATH" ]; then
    echo "Error: Could not find Firefox profile directory."
    exit 1
fi

# Create a symlink from our Stow structure to the real profile
ln -s "$SCRIPT_DIR/user.js" "$REAL_PROFILE_PATH/user.js"
