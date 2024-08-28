# Arguments
# -m (mode): region, screen
# -d (directory): An optional directory path to save the image
while getopts m:d:f: flag
do
    case "${flag}" in
        m) mode=${OPTARG};;
        d) directory=${OPTARG};;
        f) format=${OPTARG};;
    esac
done

cacheDirectory="$HOME/.cache/screencasts"
filePrefix="Screen Recording"

if [ -z "${directory}" ]; then
	directory="$HOME/Movies/Screencasts";
fi

if [ -z "${format}" ]; then
	format="mp4";
fi

filePath="$directory/$filePrefix $(date '+%Y-%m-%d at %H:%M:%S').$format"
cacheFilePath="$cacheDirectory/$filePrefix.$format"

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
	notify-send -a "ScreenCaster T" "Recording has stopped"
	sleep 1
	ffmpeg -i "$cacheFilePath" -movflags +faststart "$filePath"
	notify-send -a "ScreenCaster T" "The video is done processing"
	thunar "$directory" &
	exit 0
fi


videoCodec="libx264"
pixelFormat="yuv420p"
audioCodec="aac"

# Remove old cache file
rm -f "$cacheFilePath"

if [ "$mode" == "region" ]; then
	# Use slurp to capture a screen area and use that for recording region
	selection="$(slurp)" && wf-recorder -g "$selection" -c "$videoCodec" -x "$pixelFormat" --audio -C "$audioCodec" --file="$cacheFilePath"
else
	wf-recorder -c "$videoCodec" --audio -C "$audioCodec" -x "$pixelFormat" --file="$cacheFilePath"
fi
