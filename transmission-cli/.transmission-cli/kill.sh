#!/bin/sh
killall transmission-cli
location_pid=$(pgrep -f "cat /dev/location")
if [ -n "$location_pid" ]; then
  kill $location_pid
fi
