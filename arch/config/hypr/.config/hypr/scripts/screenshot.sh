# Arguments
# -m (mode): region, screen
# -d (directory): An optional directory path to save the image
# -f (format): format of the screenshot ie. png, jpg
while getopts m:d:f: flag
do
    case "${flag}" in
        m) mode=${OPTARG};;
        d) directory=${OPTARG};;
        f) format=${OPTARG};;
    esac
done

filePrefix="screenshot"

if [[ -z "${directory}" ]]; then
	directory="$HOME/Pictures/Screenshots";
fi

if [[ -z "${format}" ]]; then
	format="png";
fi

# Ensure the directory exists
mkdir -p "$directory"

filePath="$directory/$filePrefix-$(date '+%Y%m%d-%H:%M:%S').$format"

echo $filePath

if [[ $mode == "region" ]]; then
	grim -g "$(slurp)" - | satty --filename - --fullscreen --early-exit --copy-command "wl-copy --type image/png" --output-filename "$filePath"
elif [[ $mode == "window" ]]; then
	grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | satty --filename - --fullscreen --early-exit --copy-command "wl-copy --type image/png" --output-filename "$filePath"
else
	grim -g "$(slurp -o -r)" - | satty --filename - --fullscreen --early-exit --copy-command "wl-copy --type image/png" --output-filename "$filePath"
fi
