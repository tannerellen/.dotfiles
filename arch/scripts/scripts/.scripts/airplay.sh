#!/bin/bash

if [[ -z "$1" ]]; then
	echo "Usage: $0 <start or stop>"
	exit 1
fi

if [[ "$1" = "start" ]]; then
	uxplay &
elif [[ "$1" = "stop" ]]; then
	pkill uxplay
fi
