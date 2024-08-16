#!/bin/bash

# Sleep to wait until system is started so launching apps goes smoothly
sleep 3

# Launch 1password 
ELECTRON_OZONE_PLATFORM_HINT=x11 /usr/bin/1password --silent "$@"
