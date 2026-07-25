#!/bin/bash
# Usage: ./ubisoft-killer.sh <drive_letter> <exe_name> [launch_count]
# Example: ./ubisoft-killer.sh Z TheLostCrown.exe 2

DRIVE_LETTER="$1"
EXE_NAME="$2"
LAUNCH_COUNT="${3:-1}"

if [ -z "$DRIVE_LETTER" ] || [ -z "$EXE_NAME" ]; then
    echo "Usage: $0 <drive_letter> <exe_name> [launch_count]"
    echo "Example: $0 Z TheLostCrown.exe 2"
    exit 1
fi

PATTERN="${DRIVE_LETTER}:.*${EXE_NAME}"

is_running() {
    pgrep -f "$PATTERN" > /dev/null
}

echo "Waiting for $EXE_NAME to start (need $LAUNCH_COUNT launch(es))..."

detection_count=0
was_running=false

while [ "$detection_count" -lt "$LAUNCH_COUNT" ]; do
    if is_running; then
        if ! $was_running; then
            # Rising edge - process just appeared, confirm it's not a blip
            sleep 2
            if is_running; then
                detection_count=$((detection_count + 1))
                echo "Detection $detection_count/$LAUNCH_COUNT confirmed."
                was_running=true
            fi
        fi
    else
        was_running=false
    fi
    sleep 1
done

echo "$EXE_NAME confirmed running (launch $LAUNCH_COUNT/$LAUNCH_COUNT). Now monitoring for exit..."

# Now monitor for the final instance's exit
while is_running; do
    sleep 1
done

# Process has exited, kill upc.exe
echo "$EXE_NAME is not running. Killing upc.exe..."
pkill -f "upc.exe"
