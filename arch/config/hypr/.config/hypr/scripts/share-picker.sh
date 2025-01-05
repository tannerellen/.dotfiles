#!/bin/bash

monitors=$(wlr-randr --json | jq '.[] | .name')
windows="${XDPH_WINDOW_SHARING_LIST}"

result=""

# Add monitors to result
while IFS= read -r monitor; do
    monitor=$(echo "$monitor" | tr -d '"')  # Remove quotes from monitor name
    if [ -n "$result" ]; then
        result="${result}\n"
    fi
    result="Screen: ${result}${monitor}"
done <<< "$monitors"

# Add region entry
if [ -n "$result" ]; then
    result="${result}\n"
fi
result="${result}Selection: region"

# Add windows to result
while IFS= read -r line; do
    if [ -n "$result" ]; then
        result="${result}\n"
    fi
    result="${result}${line}"
done < <(echo "$windows" | awk -F'\\[HE>\\]' '{
    for(i=1; i<=NF; i++) {
        if ($i == "") continue;

        split($i, window, "\\[HC>\\]");
        id = window[1];

        split(window[2], parts, "\\[HT>\\]");
        class = parts[1];
        title = parts[2];

        if (id != "")
            print "Window: " title " :: " id;
    }
}')

selection=$(echo -e "$result" | fuzzel -d)

if [[ $selection == *"Screen"* ]]; then
    monitor=$(echo "$selection" | awk -F': ' '{print $NF}')
    echo "[SELECTION]/screen:${monitor}"
elif [[ $selection == *"region"* ]]; then
    region=$(slurp -f "%o@%x,%y,%w,%h")
    echo "[SELECTION]/region:${region}"
elif [[ $selection == *"Window"* ]]; then
    window_id=$(echo "$selection" | awk -F' :: ' '{print $NF}')
    echo "[SELECTION]/window:${window_id}"
fi
