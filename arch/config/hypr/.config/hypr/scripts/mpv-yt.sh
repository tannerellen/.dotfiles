#!/bin/bash

hyprhelpr indicator start loading

# Launch MPV with IPC socket
SOCKET="/tmp/mpv-yt-socket.$$"
mpv --wayland-app-id=mpv-yt --input-ipc-server="$SOCKET" "$@" &
MPV_PID=$!

# Wait for socket to exist (max 10s)
timeout=10
while [[ ! -S "$SOCKET" && $timeout -gt 0 ]]; do
    sleep 0.5
    ((timeout--))
done

if [[ ! -S "$SOCKET" ]]; then
    echo "MPV IPC socket not found!" >&2
    hyprhelpr indicator stop
    exit 1
fi

# Wait until playback is fully active (not just unpaused)
timeout=20  # Max 20s wait
while [[ $timeout -gt 0 ]]; do
    # Check if paused (must be false)
    pause_response=$(echo '{ "command": ["get_property", "pause"] }' | socat - "$SOCKET" 2>/dev/null)
    if [[ "$pause_response" != *'"data":false'* ]]; then
        sleep 1
        ((timeout--))
        continue
    fi

    # Check if time remaining is decreasing (video is progressing)
    time_response=$(echo '{ "command": ["get_property", "time-remaining"] }' | socat - "$SOCKET" 2>/dev/null)
    if [[ "$time_response" == *'"data":'* ]]; then
        # If time-remaining exists and is decreasing, playback is active!
        break
    fi

    sleep 0.5
    ((timeout--))
done

hyprhelpr indicator stop  # Only stops when playback is confirmed
wait "$MPV_PID"           # Optional: Wait for MPV to exit
rm -f "$SOCKET"           # Clean up
