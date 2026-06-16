#!/bin/bash

# Ask where to deploy
echo ""
while [[ -z "$choice" ]]; do
    read -p "Upload to directory [e]xpires, [p]ermanent, [c]ancel? : " choice
done
echo ""

# If canceled then exit
if [[ "$choice" = "c" ]]; then
	echo "Cancelled"
	exit 1
elif [[ "$choice" = "e" ]]; then
	castui --upload --interactive --clipboard
elif [[ "$choice" = "p" ]]; then
	castui --upload --interactive --clipboard --permanent
fi


