#!/bin/bash
#!/bin/bash

# Check if Waybar is running
if pgrep -x "waybar" > /dev/null; then
    echo "waybar is running"
	killall waybar
else
    echo "waybar is not running"
fi

# if pgrep waybar > /dev/null; then
#
# 	# Attempt to kill waybar, but ignore any errors
# 	# pkill waybar
# 	echo "waybar terminated"
# else
# 	echo "waybar was not running."
# fi

# Start waybar
echo "Starting waybar..."
hyprctl dispatch exec waybar

# Check if the command was successful
if [[ $? -eq 0 ]]; then
    echo "waybar started successfully."
else
    echo "Failed to start waybar."
fi

exit 0

