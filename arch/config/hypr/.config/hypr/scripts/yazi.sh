#!/bin/bash
# Yazi will switch shell to current directory on exit
tmp=$(mktemp -t "yazi-cwd.XXXXXX") 
yazi "$@" --cwd-file="$tmp"
dir=$(cat -- "$tmp")
if [ -n "$dir" ] && [ "$dir" != "$PWD" ]; then
	cd "$dir" || { echo "Failed to change directory to $dir"; exit 1; }
fi
rm -f "$tmp"
