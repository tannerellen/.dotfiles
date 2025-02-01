#!/bin/bash

# Configuration

filePath=$(cat)
fileName=$(basename "$filePath")

# AWS upload config
s3Bucket="seedcodevideos"
s3FilePath="expires"
s3Region="us-west-1"

# End config and setup

# Url encode the filename so we can build a url
#
# Base 64 encode the filename as we will use that
encodedLocation=$(echo -n $fileName | base64)
watchUrl="https://watch.dayback.com/?s=$encodedLocation"

echo "$watchUrl" | wl-copy

aws s3 cp "$filePath" "s3://$s3Bucket/$s3FilePath/"
rm "$filePath"
notify-send -a "HyprHelpr" "Video upload was successful and the URL was copied to the clipboard"
