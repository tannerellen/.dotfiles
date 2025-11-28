#!/bin/bash

if [ -n "$1" ]; then
	initialTab="--tab $1"
else
	initialTab=""
fi

kitty --class 'audio-settings' -e bash -c "wiremix $initialTab"

