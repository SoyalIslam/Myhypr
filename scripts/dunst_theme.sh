#!/usr/bin/env bash

# Pywal colors or Cyberpunk defaults
WAL_COLORS="$HOME/.cache/wal/colors.sh"
DUNST_CONFIG="$HOME/.config/dunst/dunstrc"

if [ -f "$WAL_COLORS" ]; then
    . "$WAL_COLORS"
fi

BG="${background:-#0f111a}"
FG="${foreground:-#e1e6f0}"
C0="${color0:-#15161e}"
C1="${color1:-#ff5370}"
C2="${color2:-#c3e88d}"
C3="${color3:-#ffcb6b}"
C4="${color4:-#82aaff}"
C5="${color5:-#c792ea}"
C6="${color6:-#89ddff}"
C7="${color7:-#eeffff}"
C8="${color8:-#464b5d}"

mkdir -p "$HOME/.config/dunst"

cat <<EOF > "$DUNST_CONFIG"
# Dunst Cyberpunk / Glassmorphism Configuration
# Automatically generated & synced with Pywal

[global]
    ### Display & Monitor ###
    monitor = 0
    follow = mouse

    ### Geometry & Position ###
    width = (280, 380)
    height = (60, 300)
    origin = top-right
    offset = (32, 56)
    scale = 0
    notification_limit = 5

    ### Progress Bar ###
    progress_bar = true
    progress_bar_height = 8
    progress_bar_frame_width = 0
    progress_bar_min_width = 150
    progress_bar_max_width = 260
    progress_bar_corner_radius = 4
    progress_bar_corners = all

    ### Styling & Layout ###
    font = JetBrainsMono Nerd Font 10
    line_height = 3
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    vertical_alignment = center
    show_age_threshold = 60
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = false

    ### Icons ###
    icon_position = left
    min_icon_size = 32
    max_icon_size = 48
    icon_corner_radius = 8
    icon_corners = all
    icon_theme = "Adwaita, hicolor"
    enable_recursive_icon_lookup = true

    ### Borders & Spacing ###
    corner_radius = 10
    corners = all
    frame_width = 2
    separator_height = 2
    gap_size = 8
    padding = 14
    horizontal_padding = 18
    text_icon_padding = 14

    ### Mouse Interaction ###
    mouse_left_click = close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all

[urgency_low]
    background = "${BG}ee"
    foreground = "${FG}"
    frame_color = "${C8}"
    highlight = "${C4}"
    timeout = 4

[urgency_normal]
    background = "${BG}ee"
    foreground = "${FG}"
    frame_color = "${C4}"
    highlight = "${C6}"
    timeout = 6

[urgency_critical]
    background = "${BG}f5"
    foreground = "#ffffff"
    frame_color = "${C1}"
    highlight = "${C1}"
    timeout = 0

[brightness_tag]
    stack_tag = "brightness"
    highlight = "${C6}"
    frame_color = "${C6}"
    timeout = 2

[volume_tag]
    stack_tag = "volume"
    highlight = "${C5}"
    frame_color = "${C5}"
    timeout = 2
EOF

# Restart / reload dunst to guarantee changes take effect immediately
pkill -9 dunst 2>/dev/null
dunst &
