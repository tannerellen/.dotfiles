#!/bin/bash
MINUTES="${1:-5}"

while true; do
    curl wttr.in/lake+stevens+wa
    sleep "$((MINUTES * 60))"
done
