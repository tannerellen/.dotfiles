#!/usr/bin/env bash
# Switches the default audio output by type
#
# Usage:
#   ./audio-output-select.sh <speakers|headphones|airpods>

set -euo pipefail # Fail fast and loud

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
die()   { echo -e "${RED}[✗]${NC} $*" >&2; exit 1; }

[[ $# -ge 1 ]] || die "Usage: $0 <speakers|headphones|airpods>"

OPTION="${1,,}"  # lowercase

if compgen -G "/sys/class/power_supply/BAT*" > /dev/null 2>&1; then
    # ── Laptop ────────────────────────────────────────────────────────────────
    info "Detected: laptop"
    case "$OPTION" in
        speakers)   ~/.scripts/audio-output.sh "Ryzen HD Audio Controller" ;;
        headphones) ~/.scripts/audio-output.sh "Ryzen HD Audio Controller" ;;
        airpods)    ~/.scripts/airpods-connect.sh "AirPods Pro" ;;
        *)          die "Unknown option '$1'. Valid options: speakers, headphones, airpods" ;;
    esac
else
    # ── Desktop ───────────────────────────────────────────────────────────────
    info "Detected: desktop"
    case "$OPTION" in
        speakers)   ~/.scripts/audio-output.sh "USB Audio" speaker ;;
        headphones) ~/.scripts/audio-output.sh "USB-C to 3.5mm Headphone Jack" ;;
        airpods)    ~/.scripts/airpods-connect.sh "AirPods Pro" ;;
        *)          die "Unknown option '$1'. Valid options: speakers, headphones, airpods" ;;
    esac
fi
