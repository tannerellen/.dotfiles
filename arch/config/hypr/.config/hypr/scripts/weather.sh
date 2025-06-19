#!/bin/bash

# # Get the current location based on external ip address.
# # ifconfig.me get's external ip then ipapi gets the location from that
location=$(curl -s "https://ipapi.co/$(curl -s ifconfig.me)/json/" | jq -r '"\(.city)+\(.region_code)"' | sed 's/ /+/g')
#
# # Get the weather from wttr formatted to just icon and temp
weather=$(curl -s wttr.in/"$location"?format="%c+%t")
#
if [[ "$weather" == "Unknown"* ]]; then
    echo "?"
	exit;
fi
#
# # Convert the temp to fahrenheit remove excess whitespace and other formatting
output=$(echo "$weather" | \
    sed -e 's/  \+/ /g' \
        -e 's/+//g' \
        -e 's/°C//g' | \
    awk '{
        if (match($0, /-?[0-9]+/)) {
            temp = substr($0, RSTART, RLENGTH);
            fahrenheit = (temp * 9/5) + 32;
            fahrenheit = int(fahrenheit + 0.5);
            gsub(/-?[0-9]+/, fahrenheit "°");
        }
        print $0
    }')

echo "$output"
