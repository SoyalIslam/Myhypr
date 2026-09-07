#!/bin/bash

# State & notifications
STATE_FILE="/tmp/brightness_val"
LOCK_FILE="/tmp/brightness_hw.lock"
NOTIF_ID=25632

# Adjust brightness using brightnessctl (laptop / sysfs backlight)
use_brightnessctl() {
    local change="$1"
    brightnessctl set "$change" >/dev/null 2>&1
    local current
    current=$(brightnessctl -c backlight -m 2>/dev/null | cut -d',' -f4 | tr -d '%')
    echo "${current:-50}"
}

# Adjust brightness using ddcutil (external monitors)
use_ddcutil() {
    local change="$1"
    
    # Auto-detect ddcutil bus if not cached or if invalid
    local bus_file="/tmp/ddcutil_bus"
    local bus=""
    if [ -f "$bus_file" ]; then
        bus=$(cat "$bus_file" 2>/dev/null)
    fi
    if ! [[ "$bus" =~ ^[0-9]+$ ]]; then
        bus=$(ddcutil detect 2>/dev/null | awk '/I2C bus:/ {print $3}' | grep -o '[0-9]*' | head -n1)
        if [[ "$bus" =~ ^[0-9]+$ ]]; then
            echo "$bus" > "$bus_file"
        else
            bus="2"
        fi
    fi

    # Read current state value and recover if file is missing or corrupted
    local val=""
    if [ -f "$STATE_FILE" ]; then
        val=$(cat "$STATE_FILE" 2>/dev/null)
    fi

    if ! [[ "$val" =~ ^[0-9]+$ ]]; then
        local init_val
        init_val=$(ddcutil getvcp 10 --bus "$bus" --brief 2>/dev/null | awk '/VCP 10/ {print $4}' | grep -o '^[0-9]\+$' | head -n1)
        val="${init_val:-50}"
    fi

    if [ "$change" == "+" ]; then
        val=$((val + 5))
    else
        val=$((val - 5))
    fi

    [ "$val" -gt 100 ] && val=100
    [ "$val" -lt 0 ] && val=0

    echo "$val" > "$STATE_FILE"

    (
        flock -x 9
        local target
        target=$(cat "$STATE_FILE" 2>/dev/null)
        if [[ "$target" =~ ^[0-9]+$ ]]; then
            ddcutil --bus "$bus" setvcp 10 "$target" --noverify --brief > /dev/null 2>&1
        fi
    ) 9>"$LOCK_FILE" &

    echo "$val"
}

# 1. Determine controller: sysfs backlight (laptop) vs ddcutil (desktop monitor)
max_b=$(brightnessctl -c backlight m 2>/dev/null || echo 0)
if [ "$max_b" -gt 1 ]; then
    if [ "$1" == "+" ]; then
        new_val=$(use_brightnessctl "5%+")
    else
        new_val=$(use_brightnessctl "5%-")
    fi
elif command -v ddcutil >/dev/null 2>&1; then
    new_val=$(use_ddcutil "$1")
else
    new_val=50
fi

# 2. Display OSD Notification via Dunst
dunstify -u low -r "$NOTIF_ID" -h string:x-dunst-stack-tag:brightness -h int:value:"${new_val:-50}" "Brightness" "${new_val:-50}%" -t 1500

