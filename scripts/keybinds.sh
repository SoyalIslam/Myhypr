#!/usr/bin/env bash

# Define the rofi theme to use
ROFI_THEME="$HOME/.config/rofi/launchers/type-1/style-8.rasi"

# Get keybindings from hyprctl, convert to valid JSON via Python, format them, and map to simple, friendly names
hyprctl binds | python3 -c '
import sys, json

binds = []
current = {}
for line in sys.stdin:
    stripped = line.strip()
    if stripped.startswith("bind") and ":" not in stripped:
        if current:
            binds.append(current)
            current = {}
    elif ":" in stripped:
        k, v = stripped.split(":", 1)
        k = k.strip()
        v = v.strip()
        if k == "modmask":
            try:
                v = int(v)
            except ValueError:
                v = 0
        current[k] = v
if current:
    binds.append(current)

print(json.dumps(binds))
' | jq -r '
.[] | 
# Filter out empty keys
select(.key != "") |

(([if (.modmask / 64 % 2 >= 1) then "🐧" else empty end, 
   if (.modmask / 8 % 2 >= 1) then "Alt" else empty end, 
   if (.modmask / 4 % 2 >= 1) then "Ctrl" else empty end, 
   if (.modmask / 1 % 2 >= 1) then "Shift" else empty end] | join(" + ")) as $m | 
 
 # Format the key name
 (.key | if . == "left" then "Left" elif . == "right" then "Right" elif . == "up" then "Up" elif . == "down" then "Down" else . end) as $k |

 "\($m)\(if $m == "" then "" else " + " end)\($k) -> " + 
 (if .dispatcher == "exec" then 
    (.arg | 
     if contains("type-2/launcher.sh") then "Apps" 
     elif contains("type-1/launcher.sh") then "Binds" 
     elif contains("keybinds.sh") then "Binds"
     elif contains("brightness.sh") then "Brightness" 
     elif contains("wallpaper.sh") then "Wallpaper" 
     elif contains("pavucontrol") then "Audio"
     elif contains("blueman-manager") then "Bluetooth"
     elif contains("nm-connection-editor") then "Wi-Fi"
     elif contains("rofi-power-menu") then "Power"
     elif contains("hyprlock") then "Lock"
     elif contains("grim") then "Screenshot"
     elif contains("hyprpicker") then "Color"
     elif contains("htop") then "System Usage"
     elif contains("btm") then "System Usage"
     elif contains("fastfetch") then "System Info"
     elif contains("kitty") then "Terminal"
     elif contains("dolphin") then "Files"
     elif contains("brave") then "Web"
     elif contains("dunstctl close-all") then "Clear Notifications"
     elif contains("swappy") then "Edit Screenshot"
     elif contains("playerctl next") then "Next Track"
     elif contains("playerctl previous") then "Prev Track"
     elif contains("playerctl play-pause") then "Play/Pause"
     elif contains("wpctl set-volume") then "Volume Control"
     elif contains("wpctl set-mute") then "Mute Toggle"
     else . end
    ) 
  elif .dispatcher == "workspace" then 
    (if .arg == "magic" then "Magic Workspace" elif .arg | startswith("e") then "Cycle Workspaces" else "Go to Workspace \(.arg)" end)
  elif .dispatcher == "togglespecialworkspace" then 
    (if .arg == "magic" then "Magic Workspace" else "Special Workspace \(.arg)" end)
  elif .dispatcher == "movetoworkspace" then "Move to Workspace \(.arg)"
  elif .dispatcher == "movefocus" then "Focus \($k)"
  elif .dispatcher == "movewindow" then "Move Window \($k)"
  elif .dispatcher == "killactive" then "Close Window"
  elif .dispatcher == "exit" then "Quit Hyprland"
  elif .dispatcher == "togglefloating" then "Float Window"
  elif .dispatcher == "fullscreen" then "Full Screen"
  elif .dispatcher == "togglesplit" then "Split Layout"
  elif .dispatcher == "pseudo" then "Pseudo Tiling"
  else "\(.dispatcher) \(.arg)" 
  end)
)' | sort -u | rofi -dmenu \
    -i \
    -matching fuzzy \
    -p "Search Binds" \
    -theme "$ROFI_THEME" \
    -theme-str 'listview { columns: 1; lines: 10; } window { width: 800px; }'
