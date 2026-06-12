#!/usr/bin/env bash
# airpods-connect.sh
# Connects AirPods Pro 2 via Bluetooth and sets them as the default
# PipeWire audio sink (A2DP audio-only mode — better sound quality).
#
# Usage:
#   ./airpods-connect.sh
#   ./airpods-connect.sh <Name>   # override stored name
set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
AIRPODS_NAME="${1:-"AirPods"}"
CONNECT_TIMEOUT=15
PIPEWIRE_TIMEOUT=20
# ──────────────────────────────────────────────────────────────────────────────

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[+]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
die()     { echo -e "${RED}[✗]${NC} $*" >&2; exit 1; }
require() { command -v "$1" &>/dev/null || die "Required tool not found: $1"; }

require bluetoothctl
require pactl
require awk
require grep

# ── 1. Look up MAC by device name ─────────────────────────────────────────────
info "Looking up paired device matching: '$AIRPODS_NAME'"
AIRPODS_MAC=$(bluetoothctl devices 2>/dev/null \
    | grep -i "$AIRPODS_NAME" \
    | awk '{print $2}' \
    | head -1)

[[ -n "$AIRPODS_MAC" ]] \
    || die "No paired device found matching '$AIRPODS_NAME'.\n   Check: bluetoothctl devices"
info "Found device MAC: $AIRPODS_MAC"

# Derive the stable PipeWire sink name from the MAC address.
# pactl always names BT sinks: bluez_output.<MAC_WITH_UNDERSCORES>.1
AIRPODS_SINK="bluez_output.$(echo "$AIRPODS_MAC" | tr ':' '_').1"
info "Expected sink name: $AIRPODS_SINK"

# ── 2. Make sure Bluetooth adapter is powered ─────────────────────────────────
BT_POWERED=$(bluetoothctl show | awk '/Powered:/{print $2}')
if [[ "$BT_POWERED" != "yes" ]]; then
    warn "Bluetooth adapter is off — powering on..."
    bluetoothctl power on
    sleep 1
fi

# ── 3. Connect ────────────────────────────────────────────────────────────────
CURRENT_STATE=$(bluetoothctl info "$AIRPODS_MAC" 2>/dev/null | awk '/Connected:/{print $2}')
if [[ "$CURRENT_STATE" == "yes" ]]; then
    info "AirPods already connected."
else
    info "Connecting to $AIRPODS_MAC..."
    bluetoothctl connect "$AIRPODS_MAC" &>/dev/null &
    BT_PID=$!

    elapsed=0
    while (( elapsed < CONNECT_TIMEOUT )); do
        STATE=$(bluetoothctl info "$AIRPODS_MAC" 2>/dev/null | awk '/Connected:/{print $2}')
        [[ "$STATE" == "yes" ]] && break
        sleep 1
        elapsed=$(( elapsed + 1 ))
    done

    wait "$BT_PID" 2>/dev/null || true

    STATE=$(bluetoothctl info "$AIRPODS_MAC" 2>/dev/null | awk '/Connected:/{print $2}')
    [[ "$STATE" == "yes" ]] \
        || die "Failed to connect within ${CONNECT_TIMEOUT}s. Is the device in range?"
    info "Bluetooth connected."
fi

# ── 4. Wait for PipeWire to register the sink ────────────────────────────────
# pactl list sinks short gives lines like:
#   5573  bluez_output.00_C5_85_69_B5_D8.1  PipeWire  s16le 2ch 48000Hz  SUSPENDED
info "Waiting for PipeWire sink '$AIRPODS_SINK'..."

elapsed=0
while (( elapsed < PIPEWIRE_TIMEOUT )); do
    if pactl list sinks short 2>/dev/null | awk '{print $2}' | grep -qF "$AIRPODS_SINK"; then
        break
    fi
    echo "    [${elapsed}s] sink not yet registered..."
    sleep 1
    elapsed=$(( elapsed + 1 ))
done

if ! pactl list sinks short 2>/dev/null | awk '{print $2}' | grep -qF "$AIRPODS_SINK"; then
    warn "Sink '$AIRPODS_SINK' not found after ${PIPEWIRE_TIMEOUT}s."
    warn "Available sinks:"
    pactl list sinks short | awk '{print "  " $2}' || true
    die "Aborting."
fi

info "Sink registered."

# ── 5. Set default sink via pactl ─────────────────────────────────────────────
# pactl set-default-sink writes directly to PipeWire's persistent store and
# survives WirePlumber's configured-device reassertion, unlike wpctl set-default.
info "Setting default sink → $AIRPODS_SINK"
pactl set-default-sink "$AIRPODS_SINK"

# ── 6. Confirm ────────────────────────────────────────────────────────────────
echo ""
info "Done! Active audio defaults:"
DEFAULT_SINK=$(pactl info | awk '/Default Sink:/{print $3}')
DEFAULT_SOURCE=$(pactl info | awk '/Default Source:/{print $3}')
echo "  Sink   : ${DEFAULT_SINK:-unknown}"
echo "  Source : ${DEFAULT_SOURCE:-unknown}"
