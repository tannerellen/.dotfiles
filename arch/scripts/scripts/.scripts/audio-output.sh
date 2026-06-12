#!/usr/bin/env bash
# set-sink.sh
# Sets the default PipeWire audio sink by matching one or two substrings
# against the sink's human-readable description (case-insensitive).
#
# Usage:
#   ./set-sink.sh <pattern>
#   ./set-sink.sh <pattern1> <pattern2>
#
# Examples:
#   ./set-sink.sh "USB-C to 3.5mm"
#   ./set-sink.sh "USB Audio" speakers
#   ./set-sink.sh "USB Audio" headphones
#   ./set-sink.sh airpods pro
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
die()   { echo -e "${RED}[✗]${NC} $*" >&2; exit 1; }

[[ $# -ge 1 ]] || die "Usage: $0 <pattern> [pattern2]\n   Example: $0 \"USB Audio\" speakers"

PATTERN1="${1}"
PATTERN2="${2:-}"  # optional

# ── Find matching sink index via description ──────────────────────────────────
MATCH=$(pactl list sinks 2>/dev/null \
    | awk -v p1="$PATTERN1" -v p2="$PATTERN2" '
        /^Sink #/      { idx = substr($2, 2) }
        /Description:/ {
            desc = tolower($0)
            if (!index(desc, tolower(p1))) next
            if (p2 != "" && !index(desc, tolower(p2))) next
            print idx; exit
        }
    ')

if [[ -z "$MATCH" ]]; then
    warn "No sink found matching '${PATTERN1}${PATTERN2:+ and $PATTERN2}'."
    warn "Available sinks:"
    pactl list sinks | awk '/^Sink #/{idx=substr($2,2)} /Description:/{printf "  [%s] %s\n", idx, $0}' || true
    die "Aborting."
fi

# ── Look up internal sink name from index ─────────────────────────────────────
SINK_NAME=$(pactl list sinks short | awk -v idx="$MATCH" '$1 == idx {print $2}')

info "Matched sink: [$MATCH] $SINK_NAME"

# ── Set as default ────────────────────────────────────────────────────────────
pactl set-default-sink "$SINK_NAME"

# ── Confirm ───────────────────────────────────────────────────────────────────
DEFAULT=$(pactl info | awk '/Default Sink:/{print $3}')
if [[ "$DEFAULT" == "$SINK_NAME" ]]; then
    info "Default sink is now: $DEFAULT"
else
    warn "Default sink appears to be '$DEFAULT' — may have been overridden by WirePlumber."
fi
