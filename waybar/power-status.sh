#!/bin/bash

# Detect battery
if ls /sys/class/power_supply/BAT* 1> /dev/null 2>&1; then
    capacity=$(cat /sys/class/power_supply/BAT*/capacity)
    status=$(cat /sys/class/power_supply/BAT*/status)

    if [ "$status" = "Charging" ]; then
        echo "🔌 $capacity%"
    else
        echo "🔋 $capacity%"
    fi
else
    # Desktop/Plugged status
    echo "󰚥 Plugged"
fi
