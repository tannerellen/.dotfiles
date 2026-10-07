#!/bin/sh
for f in /sys/class/leds/*::capslock/brightness; do
    if [ "$(cat "$f")" = "1" ]; then
        echo "󰘲 "
        exit 0
    fi
done
echo ""
