#!/bin/bash

s3Bucket="seedcodevideos"
s3Region="us-west-1"
s3Url="https://$s3Bucket.s3.$s3Region.amazonaws.com/$s3FilePath"

baseUrl="https://watch.dayback.com"

tmp="$(mktemp -t yazi-picker.XXXXXX)"

# Open Yazi to the specified directory
yazi "$HOME" --chooser-file "$tmp"

# Use double dash to signal end of options in case a file starts with dashes
file=$(cat -- "$tmp")
rm -f -- "$tmp"

# If canceled then exit
if [[ -z "$file" ]]; then
	echo "Upload cancelled"
	exit 1
fi

# extract the file name
fileName=$(basename "$file")

# Base 64 encode the filename as we will use that
encodedLocation=$(echo -n $fileName | base64)

sourceParam="s=$encodedLocation"

# Ask where to deploy
echo ""
while [[ -z "$choice" ]]; do
    read -p "Upload to directory [e]xpires, [p]ermanent, [c]ancel? : " choice
done
echo ""

# If canceled then exit
if [[ "$choice" = "c" ]]; then
	echo "Upload cancelled"
	exit 1
elif [[ "$choice" = "e" ]]; then
	directory="expires"
	typeParam=""
elif [[ "$choice" = "p" ]]; then
	directory="permanent"
	typeParam="t=$directory&"
fi

watchUrl="$baseUrl/?$typeParam$sourceParam"

echo "$watchUrl" | wl-copy

echo "copied to clipboard: $watchUrl"
echo ""

aws s3 cp "$file" "s3://$s3Bucket/$directory/"
