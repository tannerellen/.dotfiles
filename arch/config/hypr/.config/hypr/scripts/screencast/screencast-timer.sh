#!/bin/bash

# Arguments
# -d (displayFile): A file path to save the timer state to
# -t (timeFile): A file path to save the timer state to
# -s (signal): The waybar signal number
# -p (prefix): Optional the recording display prefix / symbol

while getopts d:t:s:p: flag
do
    case "${flag}" in
        d) displayFile=${OPTARG};;
        t) timeFile=${OPTARG};;
        s) signal=${OPTARG};;
        p) prefix=${OPTARG};;
    esac
done


if [[ -z "${displayFile}" ]]; then
	echo "Error: Missing required parameter -f."
    echo "Required to specify the file path to save timer state"
    exit 1  # Exit with error
fi

if [[ -z "${timeFile}" ]]; then
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
if [[ -f "$timeFile" ]]; then
    # Read the contents of the file into a variable
    offset=$(<"$timeFile")
else
	offset=0
fi

elapsed_time=$offset

start_time=$(($(date +%s) + offset))

# Function to display the elapsed time
display_time() {
    printf "$prefix%02d:%02d:%02d" $((elapsed_time / 3600)) $(( (elapsed_time % 3600) / 60 )) $((elapsed_time % 60)) > "$displayFile"
	echo $elapsed_time > "$timeFile"
	pkill -RTMIN+$signal waybar
}

# Start the timer
while true; do
	# Get the current time
	current_time=$(($(date +%s) + offset))
	if [[ $((start_time - current_time)) != elapsed_time ]]; then
    	display_time
	fi
    sleep 0.25
    
    # Calculate elapsed time
    elapsed_time=$((current_time - start_time + offset))
done

