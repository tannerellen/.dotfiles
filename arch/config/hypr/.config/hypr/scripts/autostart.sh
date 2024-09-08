#!/bin/bash

# Sleep to wait until system is started so launching apps goes smoothly
sleep 3

# Launch bluetooth manager - Running after delay to give time for daemon to start first
blueman-applet &

sleep 1

# Launch 1password
# Force running in xwayland as the browser extension won't unlock in wayland
# Scale is set otherwise it opens large on a hdpi display
# ELECTRON_OZONE_PLATFORM_HINT=x11 GDK_SCALE=1 /usr/bin/1password --silent "$@" &
/usr/bin/1password --silent "$@" &
