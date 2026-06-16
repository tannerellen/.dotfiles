#!/bin/bash

# Called from hyprhelpr screencast module which pipes the filepath to the script specified 

# Configuration
filePath=$(cat)
fileName=$(basename "$filePath")

# Upload & Cleanup
castui --upload "$filePath" --clipboard
rm "$filePath"
notify-send -a "HyprHelpr" "Video upload was successful and the URL was copied to the clipboard"
