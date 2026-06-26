#!/bin/bash

# Sleep to wait until system is started so launching apps goes smoothly
sleep 2

# Launch bluetooth manager - Running after delay to give time for daemon to start first
# Don't start using bluetui now by default
# blueman-applet &

hyprhelpr wallpaper # Set a random wallpaper on start

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


# Execute slack on specific workspace because flatpak is having issues with silent on another workspace
hyprctl dispatch 'hl.dsp.focus({ workspace = "3" })'
hyprctl dispatch 'hl.dsp.exec_cmd("[workspace 3 silent] flatpak run com.slack.Slack")'
# Wait until the window appears
while ! hyprctl clients -j | grep -q "com.slack.Slack"; do
    sleep 0.5
done

# Execute thunderbird on specific workspace because flatpak is having issues with silent on another workspace
hyprctl dispatch 'hl.dsp.focus({ workspace = "4" })'
hyprctl dispatch 'hl.dsp.exec_cmd("[workspace 4 silent] flatpak run org.mozilla.thunderbird")'
# Wait until the window appears
while ! hyprctl clients -j | grep -q "org.mozilla.thunderbird"; do
    sleep 0.5
done

hyprctl dispatch 'hl.dsp.focus({ workspace = "1" })'
hyprctl dispatch 'hl.dsp.exec_cmd("[workspace 1 silent] firefox")'
hyprctl dispatch 'hl.dsp.exec_cmd("[workspace 2 silent] kitty")'
