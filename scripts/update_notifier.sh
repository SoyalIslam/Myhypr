#!/usr/bin/env bash

# Wait for desktop session to settle after login
sleep 4

# Check pacman & AUR updates
PACMAN_UPDATES=$(checkupdates 2>/dev/null | wc -l)
AUR_UPDATES=0
if command -v yay >/dev/null 2>&1; then
    AUR_UPDATES=$(yay -Qu --aur 2>/dev/null | wc -l)
elif command -v paru >/dev/null 2>&1; then
    AUR_UPDATES=$(paru -Qu --aur 2>/dev/null | wc -l)
fi

TOTAL_UPDATES=$((PACMAN_UPDATES + AUR_UPDATES))

# Exit silently if system is up to date
if [ "$TOTAL_UPDATES" -eq 0 ]; then
    exit 0
fi

SUMMARY="$TOTAL_UPDATES System Updates Available"
BODY="📦 Pacman: $PACMAN_UPDATES  |  󰏖 AUR: $AUR_UPDATES\nClick to start system update"

# Display notification with action hook
ACTION=$(dunstify -u normal \
    -i system-software-update \
    -a "System Update" \
    --action="default,Update Now" \
    --action="update,Update Now" \
    -t 15000 \
    "$SUMMARY" "$BODY")

# If user clicked notification or action button
if [ "$ACTION" = "default" ] || [ "$ACTION" = "update" ]; then
    # Detect terminal
    TERM_CMD="ghostty"
    if ! command -v ghostty >/dev/null 2>&1; then
        if command -v kitty >/dev/null 2>&1; then
            TERM_CMD="kitty"
        else
            TERM_CMD="alacritty"
        fi
    fi

    # Detect package manager
    if command -v yay >/dev/null 2>&1; then
        UPDATE_CMD="yay"
    elif command -v paru >/dev/null 2>&1; then
        UPDATE_CMD="paru"
    else
        UPDATE_CMD="sudo pacman -Syu"
    fi

    # Launch terminal update session
    $TERM_CMD -e bash -c "$UPDATE_CMD; echo ''; read -n 1 -s -r -p 'Updates finished! Press any key to exit...'" &
fi
