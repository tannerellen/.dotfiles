#!/bin/bash
set -euo pipefail # Fail immediately on any error

ACTION="${1:-}"
PLAYLIST_NAME="${2:-}"

TOKEN_DIR="$HOME/.local/share/playlist-quick-add"
TOKEN_FILE="$TOKEN_DIR/token.txt"
CIDER_URL="http://127.0.0.1:10767"
ARTWORK_FILE="/tmp/now-playing-artwork.png"

# ── Function to stop indicator ──────────────────────────────────────────────
stop_indicator() {
    local exit_code=$?
    if command -v hyprhelpr &>/dev/null; then
        hyprhelpr indicator stop 2>/dev/null || true
    fi
    return $exit_code
}
trap stop_indicator EXIT

get_auth_token() {
    mkdir -p "$TOKEN_DIR"
    chmod 700 "$TOKEN_DIR"

    notify-send "Playlist Quick Add" "Approve the request in the Cider app to continue."

    curl -s -X POST "$CIDER_URL/api/v2/auth/request" \
        -H "Content-Type: application/json" \
        -d '{
            "app_name": "Playlist Quick Add",
            "app_image": "https://example.com/logo.png",
            "scopes": ["playback", "library"]
        }' | jq -r '.data.token' > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
}

# Makes a request against the Cider API, retrying once with a fresh token
# if the first attempt looks like an auth failure.
# Sets globals: LAST_HTTP_CODE, LAST_BODY
cider_request() {
    local method="$1"
    local path="$2"
    local data="${3:-}"
    local attempt

    for attempt in 1 2; do
        local response http_code body

        if [ -n "$data" ]; then
            response=$(curl -s -w '\n%{http_code}' -X "$method" "$CIDER_URL$path" \
                -H "apptoken: $APP_TOKEN" \
                -H 'Content-Type: application/json' \
                -d "$data")
        else
            response=$(curl -s -w '\n%{http_code}' -X "$method" "$CIDER_URL$path" \
                -H "apptoken: $APP_TOKEN")
        fi

        http_code=$(echo "$response" | tail -n1)
        body=$(echo "$response" | sed '$d')

        # 401/403 = auth failure. Refresh the token and retry once.
        if { [ "$http_code" == "401" ] || [ "$http_code" == "403" ]; } && [ "$attempt" -eq 1 ]; then
            echo "Token appears invalid (HTTP $http_code). Refreshing token..." >&2
            get_auth_token
            APP_TOKEN=$(cat "$TOKEN_FILE")
            continue
        fi

        LAST_HTTP_CODE="$http_code"
        LAST_BODY="$body"
        return 0
    done
}

find_playlist_id() {
    local name="$1"
    local offset=0
    local limit=50
    local total
    local match

    while true; do
        cider_request "GET" "/api/v2/library/playlists?offset=$offset&limit=$limit"
        local page="$LAST_BODY"

        match=$(echo "$page" | jq -r --arg name "$name" \
            '[.data.items[] | select(.name == $name)][0].id // empty')

        if [ -n "$match" ]; then
            echo "$match"
            return 0
        fi

        total=$(echo "$page" | jq -r '.meta.total')
        offset=$((offset + limit))

        if [ "$offset" -ge "$total" ]; then
            return 1
        fi
    done
}

# Show loading indicator if available
if command -v hyprhelpr &>/dev/null; then
	echo "Starting hyprhelpr indicator..."
	hyprhelpr indicator start loading 2>/dev/null || true
else
	echo "hyprhelpr not found, skipping indicator"
fi


# --- Auth ---
if [ -f "$TOKEN_FILE" ]; then
    APP_TOKEN=$(cat "$TOKEN_FILE")
fi

if [ -z "${APP_TOKEN:-}" ] || [ "$APP_TOKEN" == "null" ]; then
    get_auth_token
    APP_TOKEN=$(cat "$TOKEN_FILE")
fi

# --- Now playing ---
cider_request "GET" "/api/v2/playback/now-playing"

if [ "$LAST_HTTP_CODE" -ge 400 ]; then
    echo "Error: now-playing request failed (HTTP $LAST_HTTP_CODE): $LAST_BODY" >&2
    notify-send "Playlist Quick Add" "Failed to reach Cider (HTTP $LAST_HTTP_CODE)"
    exit 1
fi

NOW_PLAYING="$LAST_BODY"

ARTIST_NAME=$(echo "$NOW_PLAYING" | jq -r '.data.artistName')
ALBUM_NAME=$(echo "$NOW_PLAYING" | jq -r '.data.albumName')
IN_LIBRARY=$(echo "$NOW_PLAYING" | jq -r '.data.inLibrary')
SONG_NAME=$(echo "$NOW_PLAYING" | jq -r '.data.name')
SONG_ID=$(echo "$NOW_PLAYING" | jq -r '.data.playParams.id')
ARTWORK_URL=$(echo "$NOW_PLAYING" | jq -r '.data.artwork.url')

if [ -z "$SONG_ID" ] || [ "$SONG_ID" == "null" ]; then
    echo "Error: Nothing appears to be playing." >&2
    notify-send "Playlist Quick Add" "Nothing is currently playing."
    exit 1
fi

echo "Artist: $ARTIST_NAME"
echo "Album: $ALBUM_NAME"
echo "In Library: $IN_LIBRARY"
echo "Song: $SONG_NAME"
echo "ID: $SONG_ID"
echo "Artwork URL: $ARTWORK_URL"

# --- Add to playlist ---
if [ "$ACTION" == "add" ]; then
    if [ -z "$PLAYLIST_NAME" ]; then
        echo "Error: 'add' requires a playlist name." >&2
        echo "Usage: $0 add \"Playlist Name\"" >&2
        exit 1
    fi

    if ! PLAYLIST_ID=$(find_playlist_id "$PLAYLIST_NAME"); then
        echo "Error: No playlist found with name: $PLAYLIST_NAME" >&2
        notify-send "Playlist Quick Add" "No playlist found named \"$PLAYLIST_NAME\""
        exit 1
    fi

    echo "Found playlist \"$PLAYLIST_NAME\" with ID: $PLAYLIST_ID"
    echo "Adding \"$SONG_NAME\" to playlist: $PLAYLIST_NAME"

    cider_request "POST" "/api/v2/playlists/$PLAYLIST_ID/tracks" \
        "{\"tracks\":[{\"id\":\"$SONG_ID\",\"type\":\"library-songs\"}]}"

    if [ "$LAST_HTTP_CODE" -ge 200 ] && [ "$LAST_HTTP_CODE" -lt 300 ]; then
        echo "Added successfully."
        if curl -s -f -o "$ARTWORK_FILE" "$ARTWORK_URL"; then
            notify-send -i "$ARTWORK_FILE" "Added to $PLAYLIST_NAME" "$SONG_NAME — $ARTIST_NAME"
        else
            notify-send "Added to $PLAYLIST_NAME" "$SONG_NAME — $ARTIST_NAME"
        fi
    else
        echo "Error adding track (HTTP $LAST_HTTP_CODE): $LAST_BODY" >&2
        notify-send "Playlist Quick Add" "Failed to add track (HTTP $LAST_HTTP_CODE)"
        exit 1
    fi
fi

# --- Now-playing notification (only when not adding, to avoid duplicate notifications) ---
if [ "$ACTION" != "add" ]; then
    if curl -s -f -o "$ARTWORK_FILE" "$ARTWORK_URL"; then
        notify-send -i "$ARTWORK_FILE" "$SONG_NAME" "$ALBUM_NAME - $ARTIST_NAME"
    else
        notify-send "$SONG_NAME" "$ALBUM_NAME - $ARTIST_NAME"
    fi
fi
