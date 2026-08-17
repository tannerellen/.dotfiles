#!/usr/bin/env bash
hyprshutdown -t 'Rebooting...' --post-cmd 'uwsm-stop; systemctl reboot'
