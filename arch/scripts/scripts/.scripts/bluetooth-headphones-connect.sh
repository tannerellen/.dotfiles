#!/usr/bin/env bash
# bluetooth-headphones-connect.sh
# Connects Bluetooth headphones and sets as default PipeWire sink
#
# USAGE:
#   ./bluetooth-headphones-connect.sh [DEVICE_NAME]
#
# OPTIONS (set as environment variables):
#   NO_TEST=1          - Skip the test tone
#   TEST_SOUND=1       - Enable test tone (default)
#   DEBUG=1            - Show debug output
#   QUIET=1            - Suppress all output except errors
#   TIMEOUT=30         - Override connection timeout (default: 25)
#
# EXAMPLES:
#   # Basic usage
#   ./bluetooth-headphones-connect.sh "Airpods Pro"
#
#   # Skip test sound
#   NO_TEST=1 ./bluetooth-headphones-connect.sh "Sony WH-1000XM4"
#
#   # Debug mode
#   DEBUG=1 ./bluetooth-headphones-connect.sh "Bose QC35"
#
#   # Quiet mode (no output unless error)
#   QUIET=1 ./bluetooth-headphones-connect.sh "Airpods Pro"
#
#   # Custom timeout
#   TIMEOUT=30 ./bluetooth-headphones-connect.sh "My Headphones"
set -euo pipefail
# ── Configuration ─────────────────────────────────────────────────────────────
DEVICE_NAME="${1:-"AirPods"}"
CONNECT_TIMEOUT="${TIMEOUT:-25}"
PIPEWIRE_TIMEOUT=15
RETRY_ATTEMPTS=2
PROFILE_SETTLE_TIME=1
# ──────────────────────────────────────────────────────────────────────────────
# ── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
# ── Verbosity levels ────────────────────────────────────────────────────────
if [[ -n "${DEBUG:-}" ]]; then
    info()    { echo -e "${GREEN}[+]${NC} $*" >&2; }
    warn()    { echo -e "${YELLOW}[!]${NC} $*" >&2; }
    debug()   { echo -e "${BLUE}[debug]${NC} $*" >&2; }
elif [[ -n "${QUIET:-}" ]]; then
    info()    { :; }
    warn()    { echo -e "${YELLOW}[!]${NC} $*" >&2; }
    debug()   { :; }
else
    info()    { echo -e "${GREEN}[+]${NC} $*"; }
    warn()    { echo -e "${YELLOW}[!]${NC} $*" >&2; }
    debug()   { :; }
fi
die()     { echo -e "${RED}[✗]${NC} $*" >&2; exit 1; }
require() { command -v "$1" &>/dev/null || die "Required tool not found: $1"; }
if [[ -n "${DEBUG:-}" ]]; then
    debug "Running in DEBUG mode"
elif [[ -n "${QUIET:-}" ]]; then
    debug "Running in QUIET mode"
else
    debug "Running in VERBOSE mode (default)"
fi
# ── Required tools ──────────────────────────────────────────────────────────
require bluetoothctl
require pactl
require awk
require grep
require head
require sed
# ── Function to stop indicator ──────────────────────────────────────────────
stop_indicator() {
    local exit_code=$?
    if command -v hyprhelpr &>/dev/null; then
        hyprhelpr indicator stop 2>/dev/null || true
    fi
    return $exit_code
}
trap stop_indicator EXIT
# ── Helper functions ──────────────────────────────────────────────────────
is_connected() {
    local mac="$1"
    bluetoothctl info "$mac" 2>/dev/null | awk '/Connected:/{print $2}' | grep -q "yes"
}
# Find sink by MAC
find_sink_by_mac() {
    local mac="$1"
    local mac_underscore
    mac_underscore=$(echo "$mac" | tr ':' '_')

    debug "Looking for sink with MAC: $mac_underscore"

    # Try different naming patterns
    for pattern in \
        "bluez_output.${mac_underscore}.1" \
        "bluez_output.${mac_underscore}.a2dp-sink" \
        "bluez_output.${mac_underscore}"
    do
        debug "  Checking pattern: $pattern"
        local sink
        sink=$(pactl list sinks short 2>/dev/null | awk '{print $2}' | grep -E "^${pattern}$" | head -1) || true
        if [[ -n "$sink" ]]; then
            debug "  Found match: $sink"
            echo "$sink"
            return 0
        fi
    done

    # Fuzzy match fallback
    debug "  No exact match, trying fuzzy match..."
    local sink
    sink=$(pactl list sinks short 2>/dev/null | awk '{print $2}' | grep -iF "$mac_underscore" | head -1) || true
    if [[ -n "$sink" ]]; then
        debug "  Found fuzzy match: $sink"
        echo "$sink"
        return 0
    fi

    debug "  No sink found"
    return 1
}
# Wait for sink to appear
wait_for_sink() {
    local mac="$1"
    local timeout="$2"
    local elapsed=0
    local sink=""

    while (( elapsed < timeout )); do
        sink=$(find_sink_by_mac "$mac") || true
        if [[ -n "$sink" ]]; then
            echo "$sink"
            return 0
        fi
        if (( elapsed % 3 == 0 )); then
            debug "  Still waiting for sink... (${elapsed}s)"
        fi
        sleep 1
        elapsed=$(( elapsed + 1 ))
    done
    return 1
}
# Set the PipeWire/WirePlumber card profile to a2dp-sink (AAC).
# This is the step that was missing: bluez connecting the device only
# creates the *card*, it does not switch the card's profile away from
# "off", and without an active profile no sink node is ever created.
set_card_profile() {
    local mac="$1"
    local card_name="bluez_card.$(echo "$mac" | tr ':' '_')"

    debug "  Card name: $card_name"

    # Confirm the card actually exists before poking it
    if ! pactl list cards short 2>/dev/null | awk '{print $2}' | grep -qF "$card_name"; then
        debug "  Card $card_name not found yet"
        return 1
    fi

    local current_profile
    current_profile=$(pactl list cards 2>/dev/null \
        | awk -v c="$card_name" '
            $0 ~ "Name: "c {found=1}
            found && /Active Profile:/ {print $3; exit}
        ')
    debug "  Current profile: ${current_profile:-unknown}"

    if [[ "$current_profile" == "a2dp-sink" ]]; then
        debug "  Already on a2dp-sink, nothing to do"
        return 0
    fi

    info "Setting card profile → a2dp-sink (AAC)"
    if pactl set-card-profile "$card_name" a2dp-sink 2>/dev/null; then
        sleep "$PROFILE_SETTLE_TIME"
        return 0
    fi

    # AAC profile can fail to negotiate on some firmware/codec combos.
    # Fall back to plain SBC rather than leaving the card at "off".
    warn "a2dp-sink (AAC) failed, falling back to SBC..."
    if pactl set-card-profile "$card_name" a2dp-sink-sbc 2>/dev/null; then
        sleep "$PROFILE_SETTLE_TIME"
        return 0
    fi

    warn "Could not set any a2dp-sink profile on $card_name"
    return 1
}
# Set default sink with verification
set_default_sink() {
    local sink="$1"
    local mac="$2"

    info "Setting default sink → $sink"

    # Method 1: pactl
    debug "  Trying pactl set-default-sink..."
    if pactl set-default-sink "$sink" 2>/dev/null; then
        sleep 1
        local current
        current=$(pactl info 2>/dev/null | awk '/Default Sink:/{print $3}')
        if [[ "$current" == "$sink" ]]; then
            info "✅ Default sink set successfully"
            return 0
        else
            debug "  pactl command succeeded but default didn't change (current: $current)"
        fi
    else
        debug "  pactl command failed"
    fi

    # Method 2: wpctl fallback
    if command -v wpctl &>/dev/null; then
        debug "  Trying wpctl fallback..."
        local node_id
        node_id=$(wpctl status 2>/dev/null \
            | grep -A 50 "Sinks:" \
            | grep -F "$sink" \
            | grep -oP '\*?\s*\K[0-9]+(?=\.)' \
            | head -1) || true
        if [[ -n "$node_id" ]]; then
            debug "  Found node ID: $node_id"
            wpctl set-default "$node_id" 2>/dev/null || true
            sleep 1
            local current
            current=$(pactl info 2>/dev/null | awk '/Default Sink:/{print $3}')
            if [[ "$current" == "$sink" ]]; then
                info "✅ Default sink set via wpctl"
                return 0
            fi
        else
            debug "  Could not find node ID for sink"
        fi
    fi

    # Method 3: pacmd fallback (PulseAudio compatibility)
    if command -v pacmd &>/dev/null; then
        debug "  Trying pacmd fallback..."
        pacmd set-default-sink "$sink" 2>/dev/null || true
        sleep 1
        local current
        current=$(pactl info 2>/dev/null | awk '/Default Sink:/{print $3}')
        if [[ "$current" == "$sink" ]]; then
            info "✅ Default sink set via pacmd"
            return 0
        fi
    fi

    warn "⚠️  Could not verify default sink was set"
    return 1
}
# ── Main script ──────────────────────────────────────────────────────────────
# 1. Find device
info "Looking up paired device: '$DEVICE_NAME'"
DEVICE_MAC=$(bluetoothctl devices 2>/dev/null \
    | grep -i -- "$DEVICE_NAME" \
    | head -1 \
    | awk '{print $2}') || true
if [[ -z "$DEVICE_MAC" ]]; then
    echo ""
    echo "Available paired devices:"
    bluetoothctl devices 2>/dev/null | awk '{print "  " $2 " - " substr($0, index($0,$3))}'
    die "No paired device found matching '$DEVICE_NAME'"
fi
DEVICE_FULL_NAME=$(bluetoothctl devices 2>/dev/null | grep -F "$DEVICE_MAC" | cut -d' ' -f3- )
info "Found: $DEVICE_FULL_NAME ($DEVICE_MAC)"
# 2. Check if already connected
CONNECTED=$(bluetoothctl info "$DEVICE_MAC" 2>/dev/null | awk '/Connected:/{print $2}')
if [[ "$CONNECTED" == "yes" ]]; then
    info "✅ Device already connected"

    # Force the card profile before looking for a sink - this is the
    # step that was previously missing, causing the card to sit at
    # "off" with no sink node ever created.
    set_card_profile "$DEVICE_MAC" || warn "Profile switch failed, sink lookup may fail"

    info "Looking for audio sink..."
    SINK=$(find_sink_by_mac "$DEVICE_MAC") || true

    if [[ -z "$SINK" ]]; then
        info "Sink not found immediately, waiting a moment..."
        SINK=$(wait_for_sink "$DEVICE_MAC" 5) || {
            echo ""
            warn "Sink not found. Available sinks:"
            pactl list sinks short 2>/dev/null | awk '{print "  " $2}' || echo "  (none)"
            die "Could not find audio sink for $DEVICE_FULL_NAME"
        }
    fi

    info "Found sink: $SINK"
    set_default_sink "$SINK" "$DEVICE_MAC"

    SOURCE_PATTERN="bluez_source.$(echo "$DEVICE_MAC" | tr ':' '_')"
    SOURCE=$(pactl list sources short 2>/dev/null | awk '{print $2}' | grep -E "^${SOURCE_PATTERN}" | head -1) || true
    if [[ -n "$SOURCE" ]]; then
        debug "Setting default source → $SOURCE"
        pactl set-default-source "$SOURCE" 2>/dev/null || true
    fi

    echo ""
    info "🎧 Audio defaults:"
    pactl info 2>/dev/null | grep -E "Default Sink:|Default Source:" | sed 's/^/  /'
    echo ""
    info "✅ Done (fast path - was already connected)"
    exit 0
fi
# 3. Not connected - start indicator and connect
info "Device not connected. Connecting..."
if command -v hyprhelpr &>/dev/null; then
    debug "Starting hyprhelpr indicator..."
    hyprhelpr indicator start loading 2>/dev/null || true
else
    debug "hyprhelpr not found, skipping indicator"
fi
BT_POWERED=$(bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2}')
if [[ "$BT_POWERED" != "yes" ]]; then
    warn "Bluetooth is off - powering on..."
    bluetoothctl power on 2>/dev/null || die "Failed to power on Bluetooth"
    sleep 2
fi
# 4. Connect with retry logic
connected=false
attempt=1
while (( attempt <= RETRY_ATTEMPTS )); do
    info "Connection attempt $attempt/$RETRY_ATTEMPTS..."

    # Only force a disconnect on retries. Disconnecting before the very
    # first attempt just adds a race window against WirePlumber's
    # auto-profile-selection for no benefit, since there's nothing to
    # clean up yet. On retries it's still useful in case the previous
    # attempt left the device half-connected.
    if (( attempt > 1 )); then
        debug "  Disconnecting any existing connection before retry..."
        bluetoothctl disconnect "$DEVICE_MAC" 2>/dev/null || true
        sleep 1
    fi

    debug "  Running bluetoothctl connect..."
    bluetoothctl connect "$DEVICE_MAC" 2>/dev/null &
    BT_PID=$!
    elapsed=0
    while (( elapsed < CONNECT_TIMEOUT )); do
        if is_connected "$DEVICE_MAC"; then
            connected=true
            break
        fi
        if (( elapsed % 5 == 0 )); then
            echo "    [${elapsed}s] waiting for connection..."
        fi
        sleep 1
        elapsed=$(( elapsed + 1 ))
    done
    wait "$BT_PID" 2>/dev/null || true
    if [[ "$connected" == "true" ]]; then
        info "✅ Connected successfully on attempt $attempt"
        break
    else
        warn "Attempt $attempt failed"
        debug "  Connection state:"
        bluetoothctl info "$DEVICE_MAC" 2>/dev/null | grep -E "Connected|Paired|Trusted" | sed 's/^/    /' || true
        attempt=$(( attempt + 1 ))
    fi
done
if ! is_connected "$DEVICE_MAC"; then
    die "Failed to connect after ${RETRY_ATTEMPTS} attempts."
fi
# 5. Force the card profile, then wait for and set the sink
sleep 1
info "Setting audio profile..."
set_card_profile "$DEVICE_MAC" || warn "Profile switch failed, sink lookup may fail"

info "Waiting for audio sink to register..."
SINK=$(wait_for_sink "$DEVICE_MAC" "$PIPEWIRE_TIMEOUT") || {
    echo ""
    warn "Sink not found after ${PIPEWIRE_TIMEOUT}s."
    warn "Available sinks:"
    pactl list sinks short 2>/dev/null | awk '{print "  " $2}' || echo "  (none)"
    die "Could not find audio sink"
}
info "Found sink: $SINK"
set_default_sink "$SINK" "$DEVICE_MAC"
SOURCE_PATTERN="bluez_source.$(echo "$DEVICE_MAC" | tr ':' '_')"
SOURCE=$(pactl list sources short 2>/dev/null | awk '{print $2}' | grep -E "^${SOURCE_PATTERN}" | head -1) || true
if [[ -n "$SOURCE" ]]; then
    info "Setting default source → $SOURCE"
    pactl set-default-source "$SOURCE" 2>/dev/null || true
fi
# 6. Final status
echo ""
info "🎧 Audio defaults:"
pactl info 2>/dev/null | grep -E "Default Sink:|Default Source:" | sed 's/^/  /'
echo "  Device: $DEVICE_FULL_NAME ($DEVICE_MAC)"
echo ""
# 7. Test sound (controlled by environment variables)
if [[ -z "${NO_TEST:-}" ]] && [[ -z "${QUIET:-}" ]] && [[ "${TEST_SOUND:-1}" != "0" ]]; then
    if command -v speaker-test &>/dev/null; then
        info "🔊 Playing test tone in 2 seconds (press Ctrl+C to skip)..."
        sleep 2
        if [[ -n "${DEBUG:-}" ]]; then
            if speaker-test -c 2 -t sine -f 440 -l 1; then
                info "✅ Test tone played successfully!"
            else
                warn "⚠️  Test tone failed (audio may still work)"
            fi
        else
            if speaker-test -c 2 -t sine -f 440 -l 1 2>/dev/null; then
                info "✅ Test tone played successfully!"
            else
                warn "⚠️  Test tone failed (audio may still work) — rerun with DEBUG=1 for details"
            fi
        fi
    else
        debug "speaker-test not found, skipping test tone"
    fi
else
    debug "Test sound disabled"
fi
info "✅ Done!"

