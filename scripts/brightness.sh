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
    current=$(brightnessctl -m 2>/dev/null | cut -d',' -f4 | tr -d '%')
    echo "${current:-50}"
}

# Adjust brightness using ddcutil (external monitors)
use_ddcutil() {
    local change="$1"
    
    # Auto-detect ddcutil bus if not cached
    local bus_file="/tmp/ddcutil_bus"
    local bus=""
    if [ -f "$bus_file" ]; then
        bus=$(cat "$bus_file" 2>/dev/null)
    fi
    if [ -z "$bus" ]; then
        bus=$(ddcutil detect 2>/dev/null | awk '/I2C bus:/ {print $3}' | grep -o '[0-9]*' | head -n1)
        [ -n "$bus" ] && echo "$bus" > "$bus_file"
    fi
    bus="${bus:-2}"

    if [ ! -f "$STATE_FILE" ]; then
        local init_val
        init_val=$(ddcutil getvcp 10 --bus "$bus" --brief 2>/dev/null | awk '{print $4}')
        echo "${init_val:-50}" > "$STATE_FILE"
    fi

    local val
    val=$(cat "$STATE_FILE" 2>/dev/null)
    val=${val:-50}

    if [ "$change" == "+" ]; then
        val=$((val + 5))
    else
        val=$((val - 5))
    fi

    [ $val -gt 100 ] && val=100
    [ $val -lt 0 ] && val=0

    echo "$val" > "$STATE_FILE"

    (
        flock -x 9
        local target
        target=$(cat "$STATE_FILE" 2>/dev/null)
        ddcutil --bus "$bus" setvcp 10 "$target" --noverify --brief > /dev/null 2>&1
    ) 9>"$LOCK_FILE" &

    echo "$val"
}

# 1. Determine controller: sysfs backlight (laptop) vs ddcutil (desktop monitor)
max_b=$(brightnessctl m 2>/dev/null || echo 0)
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
