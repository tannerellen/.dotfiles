# Arguments
# -m (mode): region, screen
# -d (directory): An optional directory path to save the image
while getopts m:d:f:k: flag
do
    case "${flag}" in
        m) mode=${OPTARG};;
        d) directory=${OPTARG};;
        f) format=${OPTARG};;
        k) keep=${OPTARG};;
    esac
done

s3Bucket="seedcodevideos"
s3Region="us-west-1"
s3Url="https://$s3Bucket.s3.$s3Region.amazonaws.com"
cacheDirectory="$HOME/.cache/screencasts"
filePrefix="Screen Recording"

if [ -z "${directory}" ]; then
	directory="$HOME/Movies/Screencasts";
fi

if [ -z "${format}" ]; then
	format="mp4";
fi

fileName="$filePrefix $(date '+%Y-%m-%d at %H:%M:%S').$format"
filePath="$directory/$fileName"
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
	# Url encod the filename so we can build a url
	
	encodedLocation=$(echo -n "$s3Url/$fileName" | jq -sRr '@uri')
	watchUrl="https://tellen.me/vplayer?s=$encodedLocation"
	# screencastUrl="$s3Url/$encodedFileName"
	notify-send -a "ScreenCaster T" "Recording has stopped" "Processing..."
	echo "$watchUrl" | wl-copy
	sleep 1
	ffmpeg -i "$cacheFilePath" -movflags +faststart "$filePath"
	if [ "$keep" ]; then
		thunar "$directory" &
	else 
		aws s3 cp "$filePath" "s3://$s3Bucket"
		rm "$filePath"
	fi
	notify-send -a "ScreenCaster T" "The video is done processing"
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
