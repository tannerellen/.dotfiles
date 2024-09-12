#!/bin/bash

# Configuration
filePrefix="Screen Recording"
recordingIcon=" "
waybarSignal=2
cacheDirectory="$HOME/.cache/screencasts"
recordingStateFile="$HOME/.cache/recording"

s3Bucket="seedcodevideos"
s3Region="us-west-1"
s3Url="https://$s3Bucket.s3.$s3Region.amazonaws.com"

encodeQuality=25 # 23 is a good balance of speeed and quality lower numbers are better quality
videoCodec="libx264"
pixelFormat="yuv420p"
audioCodec="aac"
audioBitrate="192k"

# Arguments
# -m (mode): region, screen
# -d (directory): An optional directory path to save the image
# -f (format): An optional container format for the video. Defaults to mp4
# -k (keep): Optional if set to true the video will be kept locally instead of uploaded

while getopts m:d:f:k: flag
do
    case "${flag}" in
        m) mode=${OPTARG};;
        d) directory=${OPTARG};;
        f) format=${OPTARG};;
        k) keep=${OPTARG};;
    esac
done


if [ -z "${directory}" ]; then
	directory="$HOME/Videos/Screencasts";
fi

if [ -z "${format}" ]; then
	format="mp4";
fi

fileName="$filePrefix $(date '+%Y-%m-%d at %H:%M:%S').$format"
filePath="$directory/$fileName"
cacheFilePath="$cacheDirectory/$filePrefix.mkv"

# Get the directory of the current script
scriptDirectory="$(dirname "$(realpath "$0")")"

# Ensure the cache directory exists
mkdir -p "$cacheDirectory"
# Ensure the directory exists
mkdir -p "$directory"

# Check to see if we are already recording with wf-recorder and stop recording
# Used as a toggle to turn off recording
# running=pidof "wf-recorder"
running=$(pgrep -x "wf-recorder")
if [ "$running" ]; then
	killall wf-recorder &
	killall screencast-timer.sh
	echo "$recordingIcon processing" > "$recordingStateFile"
	pkill -RTMIN+$waybarSignal waybar

	# Url encod the filename so we can build a url
	encodedLocation=$(echo -n "$s3Url/$fileName" | jq -sRr '@uri')
	watchUrl="https://watch.dayback.com/?s=$encodedLocation"

	notify-send -a "ScreenCaster T" "Recording has stopped" "Processing..."
	echo "$watchUrl" | wl-copy

	# Sleep to make sure the wf-recorder has fully saved and exited from the initial recording
	sleep 1

	# Encode video so it works on all devices and move to final destination
	# ffmpeg -i "$cacheFilePath" -c:v $videoCodec -preset ultrafast -crf $encodeQuality -c:a $audioCodec -b:a $audioBitrate -pix_fmt $pixelFormat -movflags +faststart "$filePath"
	ffmpeg -i "$cacheFilePath" -c:v $videoCodec -preset ultrafast -crf $encodeQuality -c:a copy -pix_fmt $pixelFormat -movflags +faststart "$filePath"

	if [ "$keep" ]; then
		thunar "$directory" &
	else 
		aws s3 cp "$filePath" "s3://$s3Bucket"
		rm "$filePath"
	fi
	: > "$recordingStateFile"
	pkill -RTMIN+$waybarSignal waybar
	notify-send -a "ScreenCaster T" "The video is done processing"
	exit 0
fi

# Remove old cache file
rm -f "$cacheFilePath"

if [ "$mode" == "region" ]; then
    # Use slurp to capture a screen area and use that for recording region
    selection="$(slurp)"
    
    # Check if slurp was successful (exit status 0)
    if [ $? -eq 0 ]; then
        wf-recorder -g "$selection" --audio -C "$audioCodec" --file="$cacheFilePath" &
        # Start the timer script in the background
        "$scriptDirectory/screencast-timer.sh" -f "$recordingStateFile" -s $waybarSignal -p "$recordingIcon " &
    fi
else
	# Capture the entire screen
	wf-recorder --audio -C "$audioCodec" --file="$cacheFilePath" &
    # Start the timer script in the background
	"$scriptDirectory/screencast-timer.sh" -f "$recordingStateFile" -s $waybarSignal -p "$recordingIcon " &
fi

