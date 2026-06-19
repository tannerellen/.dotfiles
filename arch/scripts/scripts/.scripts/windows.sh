#!/bin/bash

# Config
USER=tannerellen
PASS=5555
SCALE=180
STARTING_WIDTH=1920
STARTING_HEIGHT=1080
INDICATOR_DELAY=8
# End of config

# Show indicator that things are loading
hyprhelpr indicator start loading

# Navigate to directory where docker compose file is and bring it up
cd ~/.winboat/
docker compose up -d

# Make sure docker image is running
echo "Waiting for container to assign port..."
PORT=""
TIMEOUT=30
ELAPSED=0
until [ -n "$PORT" ]; do
    if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
        echo "Timed out waiting for container to assign port after ${TIMEOUT}s" >&2
        exit 1
    fi
    PORT=$(docker compose port windows 3389 2>/dev/null | cut -d: -f2)
    sleep 1
    ELAPSED=$((ELAPSED + 1))
done
echo "Waiting for RDP port $PORT to be ready..."
ELAPSED=0
until (echo > /dev/tcp/127.0.0.1/$PORT) 2>/dev/null; do
    if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
        echo "Timed out waiting for RDP port after ${TIMEOUT}s" >&2
        exit 1
    fi
    sleep 1
    ELAPSED=$((ELAPSED + 1))
done
 
# Stop the indicator asynchronously after a short delay, so it stays up just
# long enough to cover the RDP handshake lag instead of cutting off the instant
# the port opens. This runs in the background so it doesn't block freerdp launch.
( sleep $INDICATOR_DELAY && hyprhelpr indicator stop ) &

# Connect to windows
flatpak run --command=xfreerdp com.freerdp.FreeRDP \
/u:$USER /p:$PASS \
/v:127.0.0.1 /port:$PORT /cert:ignore \
+clipboard \
/sound:sys:pulse /microphone:sys:pulse \
/floatbar /network:lan /gfx:avc420 \
/w:$STARTING_WIDTH /h:$STARTING_HEIGHT \
/dynamic-resolution \
/scale-desktop:$SCALE \
+fonts
#
# "/wm-class:FileMaker Pro" \
# "/app:program:C:\Program Files\FileMaker\FileMaker Pro 19\FileMaker Pro.EXE,name:FileMaker Pro" \
#
# FreeRDP has exited — stop the docker container
hyprhelpr indicator start loading
echo "FreeRDP session ended. Stopping WinBoat container..."
docker compose stop
hyprhelpr indicator stop 
#
# Launch winboat with the following launch options:
# /path/to/winboat-0.9.0-x86_64.AppImage --enable-features=Vulkan --use-gl=angle --use-angle=vulkan
#
# https://www.reddit.com/r/Ubuntu/comments/1u6igp4/looking_for_microsoft_365_within_linux_i_think/
