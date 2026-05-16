#!/bin/bash

# Use yazi to select a file
selected=$(yazi --chooser-file=/dev/stdout . 2>/dev/null)

if [[ -z "$selected" ]]; then
    echo "No file selected."
    exit 1
fi

echo "Selected: $selected"
echo "Burning to USB with caligula..."

caligula burn "$selected"
