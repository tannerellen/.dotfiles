#!/bin/bash

# For launching web apps in a manner allowing unique process tracking for Progressive web apps for firefox

# Config: Enter the unique pwa app id and profile id reported in the extension
PWA_ID="" # Can get in the pwa extension under settings then "apps"
PROFILE_ID="" # Can get in the pwa extension under settings and "profiles"

#
# Should not need to edit below here --------------------------------->
#
~/.local/share/firefoxpwa/runtime/firefox --class FFPWA-$PWA_ID --name FFPWA-$PWA_ID --profile ~/.local/share/firefoxpwa/profiles/$PROFILE_ID --pwa $PWA_ID

# Save PID of the launched process
APP_PID=$!

# Set up trap to kill application when script exits
trap "kill $APP_PID" EXIT

# Wait for application to complete
wait $APP_PID
