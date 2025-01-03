#!/bin/bash

# Arguments
# -m (mode): Optional wether to record whole screen or region defaults to screen. region, screen
# -d (directory): An optional directory path to save the image
# -k (keep): Optional if set the video will be kept locally instead of uploaded
# -p (pause): Optional if set the video enter a paused state

# Configuration

# File and temporary directory
filePrefix="screen-recording"
cacheDirectory="$HOME/.cache/screencasts"

# AWS upload config
s3Bucket="seedcodevideos"
s3FilePath="expires"
s3Region="us-west-1"
s3Url="https://$s3Bucket.s3.$s3Region.amazonaws.com/$s3FilePath"

# Waybar config
recordingIcon=" "
pauseIcon="󰏤"
waybarSignal=2

# Video format config
format="mp4"
codec="libx264"
audioCodec="aac"


# End configuration

keep=false
pause=false

while getopts "m:d:kp" flag; do
    case "${flag}" in
        m) mode=${OPTARG};;
        d) directory=${OPTARG};;
        k) keep=true;;
        p) pause=true;;
		*) echo "Invalid option"; exit 1;;
    esac
done

# Read saved state this will assign any variables based on what is in the file
source "$recordingStateFile"

if [[ -z "${directory}" ]]; then
	directory="$HOME/Videos/Screencasts";
fi

recordingDisplayFile="$cacheDirectory/recording-display"
recordingTimeFile="$cacheDirectory/recording-time"
recordingStateFile="$cacheDirectory/recording-state"
concatListFile="$cacheDirectory/concat-list"

fileName="$filePrefix $(date '+%Y-%m-%d at %H:%M:%S').$format"
filePath="$directory/$fileName"
cacheFilePath="$cacheDirectory/$filePrefix.$format"

# Get the directory of the current script
scriptDirectory="$(dirname "$(realpath "$0")")"

# Ensure the cache directory exists
mkdir -p "$cacheDirectory"
# Ensure the directory exists
mkdir -p "$directory"

# End config and setup

# Function to stop the recording
stopRecording() {
	killall wf-recorder &
	killall screencast-timer.sh
	echo "$recordingIcon processing" > "$recordingDisplayFile"
	pkill -RTMIN+$waybarSignal waybar

	# Url encode the filename so we can build a url
	# encodedLocation=$(echo -n "$s3Url/$fileName" | jq -sRr '@uri')
	#
	# Base 64 encode the filename as we will use that
	encodedLocation=$(echo -n $fileName | base64)
	watchUrl="https://watch.dayback.com/?s=$encodedLocation"

	notify-send -a "ScreenCaster" "Recording has stopped" "Processing..."
	echo "$watchUrl" | wl-copy

	# Sleep to make sure the wf-recorder has fully saved and exited from the initial recording
	sleep 1

	if [[ -f "$concatListFile" ]]; then
		find "$cacheDirectory" -iname "*.mp4" |  sort |  sed 's:\ :\\\ :g'| sed 's/^/file /' > $concatListFile
		ffmpeg -f concat -safe 0 -i "$concatListFile" -c copy "$cacheDirectory/concat.$format"
		cp "$cacheDirectory/concat.$format" "$filePath"
	else
		cp "$cacheFilePath" "$filePath"
	fi

	if [[ $keep == true ]]; then
		thunar "$directory" &
	else 
		aws s3 cp "$filePath" "s3://$s3Bucket/$s3FilePath/"
		rm "$filePath"
	fi
	: > "$recordingDisplayFile"
	pkill -RTMIN+$waybarSignal waybar

	rm -r "$cacheDirectory/"*
	notify-send -a "ScreenCaster" "The video is done processing"
	exit 0
}

# Function to pause the recording
pauseRecording() {
	killall wf-recorder &
	killall screencast-timer.sh
	echo "$pauseIcon paused" > "$recordingDisplayFile"
	pkill -RTMIN+$waybarSignal waybar

	mv "$cacheFilePath" "$cacheDirectory/$fileName"
	# We need to run this when starting a recording too if the concat file exists
	find "$cacheDirectory" -iname "*.mp4" |  sort |  sed 's:\ :\\\ :g'| sed 's/^/file /' > $concatListFile

}

# Check to see if we are already recording with wf-recorder and stop recording
# Used as a toggle to turn off recording
# running=pidof "wf-recorder"
running=$(pgrep -x "wf-recorder")

if [[ "$running" ]]; then
	echo $pause
	if [[ $pause == true ]]; then
		pauseRecording
		exit 0
	else
		stopRecording
		exit 0
	fi
fi

if [[ $pause == false ]]; then
	# Remove old cache file
	rm -f "$cacheFilePath"
else
	cacheFilePath="$cacheDirectory/$fileName"
fi

if [[ "$mode" == "region" ]]; then
    # Use slurp to capture a screen area and use that for recording region
	if [[ -z "$selection" ]]; then
		selection="$(slurp)"
	fi
    
    # Check if slurp was successful (exit status 0)
    if [[ $? -eq 0 ]]; then
		# Save current state
		printf "$(declare -p mode)\n$(declare -p directory)\n$(declare -p selection)" >"$recordingStateFile"

		# Capture selection of screen
        wf-recorder -g "$selection" --codec "$codec" --audio -C "$audioCodec" -p preset=superfast -p vprofile=high -p level=42 --file="$cacheFilePath" &

        # Start the timer script in the background
        "$scriptDirectory/screencast-timer.sh" -d "$recordingDisplayFile" -t "$recordingTimeFile" -s $waybarSignal -p "$recordingIcon " &
    fi
else
	# Save current state
	printf "$(declare -p mode)\n$(declare -p directory)" >"$recordingStateFile"

	# Capture the entire screen
	wf-recorder --codec "$codec" --audio -C "$audioCodec" -p preset=superfast -p vprofile=high -p level=42 --file="$cacheFilePath" &

    # Start the timer script in the background
	"$scriptDirectory/screencast-timer.sh" -d "$recordingDisplayFile" -t "$recordingTimeFile" -s $waybarSignal -p "$recordingIcon " &
fi

