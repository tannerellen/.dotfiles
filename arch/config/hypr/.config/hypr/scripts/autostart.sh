#!/bin/bash

# Sleep to wait until system is started so launching apps goes smoothly
sleep 3

# Launch bluetooth manager - Running after delay to give time for daemon to start first
blueman-applet &

sleep 1

# Launch 1password
# Force running in xwayland as copying to the clipboard wasn't working in wayland
# Scale is set otherwise it opens large on a hdpi display
ELECTRON_OZONE_PLATFORM_HINT=x11 /usr/bin/1password --silent "$@" &
# Open using the standard wayland method - Currently disabled
# /usr/bin/1password --silent "$@" &
#
# Start wob for volume indicator
rm -f /tmp/wobpipe
mkfifo /tmp/wobpipe
tail -f /tmp/wobpipe | wob &

