#!/bin/bash

echo "Waiting for TheLostCrown.exe to start..."

# Wait for two detections with a small delay
while true; do
    if pgrep -f "Z:.*TheLostCrown.exe" > /dev/null; then
        echo "First detection - confirming..."
        sleep 2  # Wait a bit before checking again
        if pgrep -f "Z:.*TheLostCrown.exe" > /dev/null; then
            echo "TheLostCrown.exe confirmed running. Now monitoring..."
            break
        fi
    fi
    sleep 1
done

# Now monitor for the process exit
while pgrep -f "Z:.*TheLostCrown.exe" > /dev/null; do
    sleep 1
done

# Process has exited, kill upc.exe
echo "TheLostCrown.exe is not running. Killing upc.exe..."
pkill -f "upc.exe"
