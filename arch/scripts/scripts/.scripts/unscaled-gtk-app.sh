#!/bin/bash
# Script parameter is the app name
export GDK_SCALE=2
export GTK_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export GDK_BACKEND=wayland
setsid "$1" "${@:2}" &
