#!/usr/bin/env bash

## A script to update all packages on the system

set -e  # stop on first error

# Update system packages
echo ""
echo "Updating system..."
echo ""
paru -Syu

# Update flatpak
echo ""
echo "Updating flatpak apps..."
echo ""
flatpak update

# Update rust apps installed with cargo
echo ""
echo "Updating cargo apps..."
echo ""
cargo install-update -a

# Update python apps installed with uv
echo ""
echo "Updating UV apps..."
echo ""
uv tool upgrade --all
