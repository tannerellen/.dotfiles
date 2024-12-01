#!/bin/bash

# Arguments
# -f (file): A file path to save the timer state to
# -s (signal): The waybar signal number
# -p (prefix): Optional the recording display prefix / symbol

while getopts f:s:p: flag
do
    case "${flag}" in
        f) file=${OPTARG};;
        s) signal=${OPTARG};;
        p) prefix=${OPTARG};;
    esac
done

if [[ -z "${file}" ]]; then
	echo "Error: Missing required parameter -f."
    echo "Required to specify the file path to save timer state"
    exit 1  # Exit with error
fi

if [[ -z "${signal}" ]]; then
	echo "Error: Missing required parameter -s."
    echo "Required to specify the signal number for waybar to update"
    exit 1  # Exit with error
fi

# Initialize the elapsed time
elapsed_time=0
echo "$file"

# Function to display the elapsed time
display_time() {
    printf "$prefix%02d:%02d:%02d" $((elapsed_time / 3600)) $(( (elapsed_time % 3600) / 60 )) $((elapsed_time % 60)) > "$file"
	pkill -RTMIN+$signal waybar
}

# Start the timer
while true; do
    display_time
    sleep 1
    ((elapsed_time++))
done

