#!/bin/bash

# Get CPU temperature (silently)
cpu=$(sensors 2>/dev/null | awk '/Tctl/ {print $2}' | head -n1)

# Get GPU temperature (silently, NVIDIA)
gpu=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)

if [ -n "$gpu" ]; then
    echo " $cpu |  ${gpu}°C"
else
    echo " $cpu"
fi
