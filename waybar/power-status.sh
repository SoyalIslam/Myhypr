#!/bin/bash

# Find first available battery cleanly
BAT=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)

if [ -n "$BAT" ] && [ -f "$BAT/capacity" ]; then
    capacity=$(cat "$BAT/capacity" 2>/dev/null)
    status=$(cat "$BAT/status" 2>/dev/null)

    if [ "$status" = "Charging" ]; then
        echo "🔌 $capacity%"
    else
        echo "🔋 $capacity%"
    fi
else
    # Desktop/Plugged status
    echo "󰚥 Plugged"
fi
