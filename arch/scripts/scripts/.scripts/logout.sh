#!/usr/bin/env bash
hyprshutdown -t 'Logging out...' --post-cmd 'uwsm-stop; loginctl terminate-user $USER'

