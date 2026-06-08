#!/bin/bash

# For launching web apps in a manner allowing unique process tracking for Progressive web apps for firefox

# Config: Enter the unique pwa app id and profile id reported in the extension
PWA_ID="" # Can get in the pwa extension under settings then "apps"
PROFILE_ID="" # Can get in the pwa extension under settings and "profiles"
NAME="" # The name to identify this app. Used for window rules etc.

#
# Should not need to edit below here --------------------------------->
#

hyprctl dispatch "hl.dsp.exec_cmd(\"~/.local/share/firefoxpwa/runtime/firefox --class ${NAME} --name ${NAME} --profile ~/.local/share/firefoxpwa/profiles/${PROFILE_ID} --pwa ${PWA_ID}\", $1)"

