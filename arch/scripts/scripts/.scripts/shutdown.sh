#!/usr/bin/env bash
hyprshutdown -t 'Shutting down...' --post-cmd 'uwsm-stop; systemctl poweroff'

