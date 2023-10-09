#!/bin/sh
killall transmission-cli
location_pid=pgrep -f "cat /dev/location"
kill $location_pid


