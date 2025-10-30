#!/bin/bash

# Sleep to wait until system is started so launching apps goes smoothly
sleep 2

# Launch bluetooth manager - Running after delay to give time for daemon to start first
blueman-applet &


#
# Start wob for volume indicator
rm -f /tmp/wobpipe
mkfifo /tmp/wobpipe
tail -f /tmp/wobpipe | wob &

sleep 1

# Launch 1password
# Force running in xwayland as sometimes unlock window opens too small and cut off
# ELECTRON_OZONE_PLATFORM_HINT=x11 /usr/bin/1password --silent "$@" &
# Open using the standard wayland method - Currently disabled
/usr/bin/1password --silent "$@" &

# Execute applications on specific workspaces
hyprctl dispatch exec "[workspace 1 silent] firefox"
hyprctl dispatch exec "[workspace 2 silent] kitty"
hyprctl dispatch exec "[workspace 3 silent] flatpak run com.slack.Slack"
hyprctl dispatch exec "[workspace 4 silent] flatpak run org.mozilla.Thunderbird"
