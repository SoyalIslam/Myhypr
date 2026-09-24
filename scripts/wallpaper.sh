#!/bin/bash

# Ensure PATH includes ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

LOCK_FILE="/tmp/wallpaper_change.lock"

if [ -f "$LOCK_FILE" ]; then
    exit 0
fi

touch "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

# Wait for awww-daemon to be ready (timeout after 10 seconds)
timeout=0
while ! awww query >/dev/null 2>&1; do
    sleep 0.5
    ((timeout++))
    if [ $timeout -gt 20 ]; then
        echo "awww-daemon not responding, exiting"
        exit 1
    fi
done

WALL_DIR="$HOME/.config/hypr/wallpapers"
WALL=$(find "$WALL_DIR" -type f | shuf -n 1)

# Transition time reduced to 1.5 second to handle faster changes
awww img "$WALL" --transition-type random --transition-duration 1.5

# Generate colors if pywal is available
if command -v wal >/dev/null 2>&1; then
    wal -i "$WALL" -n
elif [ -x "$HOME/.local/bin/wal" ]; then
    "$HOME/.local/bin/wal" -i "$WALL" -n
fi

# Update dunst notification theme to match pywal colors
if [ -x "$HOME/.config/hypr/scripts/dunst_theme.sh" ]; then
    "$HOME/.config/hypr/scripts/dunst_theme.sh" &
fi

# Reload waybar stylesheet dynamically if running, or start it if not
if pgrep -x waybar >/dev/null 2>&1; then
    pkill -USR2 waybar
else
    waybar -c ~/.config/hypr/waybar/config -s ~/.config/hypr/waybar/style.css &
fi
