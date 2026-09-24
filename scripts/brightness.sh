#!/usr/bin/env bash

# State files & caching
STATE_FILE="/tmp/brightness_val"
CACHE_STATE="$HOME/.cache/brightness_val"
BUS_CACHE="$HOME/.cache/ddcutil_bus"
LOCK_FILE="/tmp/brightness_hw.lock"
NOTIF_ID=25632

mkdir -p "$HOME/.cache"

# Helper to get appropriate brightness icon
get_icon() {
    local val="$1"
    if [ "$val" -ge 65 ]; then
        echo "󰃠"
    elif [ "$val" -ge 30 ]; then
        echo "󰃟"
    else
        echo "󰃞"
    fi
}

# Display OSD Notification via Dunst
show_notification() {
    local val="$1"
    local icon
    icon=$(get_icon "$val")
    dunstify -u low \
        -r "$NOTIF_ID" \
        -h string:x-dunst-stack-tag:brightness \
        -h int:value:"$val" \
        -a "Brightness" \
        "$icon  Brightness" \
        "${val}%" \
        -t 1200
}

# Laptop backlight controller (sysfs / brightnessctl)
handle_backlight() {
    local action="$1"
    local step="${2:-5}"
    local val

    if [ "$action" = "+" ] || [ "$action" = "up" ]; then
        brightnessctl set "${step}%+" >/dev/null 2>&1
    elif [ "$action" = "-" ] || [ "$action" = "down" ]; then
        brightnessctl set "${step}%-" >/dev/null 2>&1
    elif [[ "$action" =~ ^[0-9]+$ ]]; then
        brightnessctl set "${action}%" >/dev/null 2>&1
    fi

    val=$(brightnessctl -c backlight -m 2>/dev/null | cut -d',' -f4 | tr -d '%')
    val="${val:-50}"
    echo "$val" > "$STATE_FILE"
    echo "$val" > "$CACHE_STATE"
    show_notification "$val"
}

# External monitor controller (DDC/CI via ddcutil)
get_ddc_bus() {
    local bus=""
    if [ -f "$BUS_CACHE" ]; then
        bus=$(cat "$BUS_CACHE" 2>/dev/null)
    fi

    # Verify that cached bus exists in sysfs
    if ! [[ "$bus" =~ ^[0-9]+$ ]] || [ ! -e "/dev/i2c-$bus" ]; then
        bus=$(ddcutil detect --brief 2>/dev/null | awk '/I2C bus:/ {print $3}' | grep -o '[0-9]*' | head -n1)
        if [[ "$bus" =~ ^[0-9]+$ ]]; then
            echo "$bus" > "$BUS_CACHE"
        else
            bus="2"
            echo "$bus" > "$BUS_CACHE"
        fi
    fi
    echo "$bus"
}

get_current_ddc_val() {
    local bus="$1"
    local val=""

    if [ -f "$STATE_FILE" ]; then
        val=$(cat "$STATE_FILE" 2>/dev/null)
    elif [ -f "$CACHE_STATE" ]; then
        val=$(cat "$CACHE_STATE" 2>/dev/null)
    fi

    if ! [[ "$val" =~ ^[0-9]+$ ]]; then
        val=$(ddcutil --bus "$bus" getvcp 10 --brief --sleep-multiplier .1 2>/dev/null | awk '/VCP 10/ {print $4}' | grep -o '^[0-9]\+' | head -n1)
        val="${val:-60}"
    fi

    echo "$val"
}

handle_ddcutil() {
    local action="$1"
    local step="${2:-5}"
    local bus
    bus=$(get_ddc_bus)
    local cur_val
    cur_val=$(get_current_ddc_val "$bus")

    local new_val="$cur_val"
    if [ "$action" = "+" ] || [ "$action" = "up" ]; then
        new_val=$((cur_val + step))
    elif [ "$action" = "-" ] || [ "$action" = "down" ]; then
        new_val=$((cur_val - step))
    elif [[ "$action" =~ ^[0-9]+$ ]]; then
        new_val="$action"
    fi

    # Clamp values between 5% and 100% to avoid completely black screen
    [ "$new_val" -gt 100 ] && new_val=100
    [ "$new_val" -lt 5 ] && new_val=5

    # Immediately save state and trigger UI notification
    echo "$new_val" > "$STATE_FILE"
    echo "$new_val" > "$CACHE_STATE"
    show_notification "$new_val"

    # Async worker process with lock:
    # If a worker is already running, it will read the latest STATE_FILE automatically.
    # If not, spawn one worker loop to apply the hardware change.
    (
        exec 9>"$LOCK_FILE"
        if ! flock -n 9; then
            exit 0
        fi

        last_applied=-1
        while true; do
            target=$(cat "$STATE_FILE" 2>/dev/null)
            if [[ "$target" =~ ^[0-9]+$ ]] && [ "$target" -ne "$last_applied" ]; then
                ddcutil --bus "$bus" setvcp 10 "$target" --noverify --sleep-multiplier .1 >/dev/null 2>&1
                last_applied="$target"
            fi

            # Check if state changed during write; if not, worker is finished
            current_target=$(cat "$STATE_FILE" 2>/dev/null)
            if [ "$current_target" = "$last_applied" ]; then
                break
            fi
        done
    ) &
}

# Fast check if laptop backlight is available
if [ -d /sys/class/backlight ] && [ -n "$(ls -A /sys/class/backlight 2>/dev/null)" ]; then
    handle_backlight "$1" "${2:-5}"
elif command -v ddcutil >/dev/null 2>&1; then
    handle_ddcutil "$1" "${2:-5}"
else
    show_notification 50
fi
