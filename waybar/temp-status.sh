#!/bin/bash

# Detect CPU Temperature (AMD, Intel, ARM, hwmon, thermal_zone)
get_cpu_temp() {
    # Try sensors first
    if command -v sensors >/dev/null 2>&1; then
        local temp
        temp=$(sensors 2>/dev/null | awk '/(Tctl|Tdie|Package id 0|CPU Temp|Core 0)/ {print $2}' | grep -o '[0-9\.]*' | head -n1)
        if [ -n "$temp" ]; then
            echo "${temp%.*}°C"
            return
        fi
    fi

    # Fallback to sysfs thermal zones
    for zone in /sys/class/thermal/thermal_zone*/temp; do
        if [ -f "$zone" ]; then
            local raw
            raw=$(cat "$zone" 2>/dev/null)
            if [ -n "$raw" ] && [ "$raw" -gt 0 ]; then
                echo "$((raw / 1000))°C"
                return
            fi
        fi
    done

    # Fallback to hwmon
    for hwmon in /sys/class/hwmon/hwmon*/temp1_input; do
        if [ -f "$hwmon" ]; then
            local raw
            raw=$(cat "$hwmon" 2>/dev/null)
            if [ -n "$raw" ] && [ "$raw" -gt 0 ]; then
                echo "$((raw / 1000))°C"
                return
            fi
        fi
    done
}

cpu=$(get_cpu_temp)

# Get GPU temperature (silently, NVIDIA)
gpu=""
if command -v nvidia-smi >/dev/null 2>&1; then
    gpu=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1)
fi

if [ -n "$gpu" ]; then
    echo " ${cpu:-N/A} |  ${gpu}°C"
elif [ -n "$cpu" ]; then
    echo " $cpu"
else
    echo " N/A"
fi
