#!/bin/bash

# Files for state
STATE_FILE="/tmp/brightness_val"
LOCK_FILE="/tmp/brightness_hw.lock"
# Constant notification ID to prevent "refreshing" animation
NOTIF_ID=25632

# 1. Initialize if not exists (first run only)
if [ ! -f "$STATE_FILE" ]; then
    ddcutil getvcp 10 --bus 2 --brief | awk '{print $4}' > "$STATE_FILE"
fi

# 2. Get current value from file
val=$(cat "$STATE_FILE")

# 3. Update value based on input
if [ "$1" == "+" ]; then
    val=$((val + 5))
else
    val=$((val - 5))
fi

# 4. Clamp between 0 and 100
[ $val -gt 100 ] && val=100
[ $val -lt 0 ] && val=0

# 5. Save back to file IMMEDIATELY
echo "$val" > "$STATE_FILE"

# 6. Update the OSD (Bar) IMMEDIATELY
# Using -r (replace) with a fixed ID is the smoothest way in Dunst
dunstify -u low -r "$NOTIF_ID" -h string:x-dunst-stack-tag:brightness -h int:value:"$val" "Brightness" "$val%" -t 1500

# 7. Sync with hardware in background
# This part is slow (~0.5s), so we run it in a subshell
(
  # Wait for current hardware sync to finish, then set the latest value
  # We use flock to ensure we don't spam the I2C bus
  flock -x 9
  
  # Read the LATEST target (might have changed while we waited for lock)
  TARGET=$(cat "$STATE_FILE")
  
  # Set hardware brightness (brief and noverify for speed)
  ddcutil --bus 2 setvcp 10 "$TARGET" --noverify --brief > /dev/null 2>&1
) 9>"$LOCK_FILE" &
