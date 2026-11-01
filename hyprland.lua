-- ==============================================================================
-- Hyprland Lua Configuration (Hyprland 0.57+)
-- Converted from legacy hyprland.conf
-- ==============================================================================

local home = os.getenv("HOME")

------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@100",
    position = "0x0",
    scale    = 1,
})

hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "auto",
    scale    = 1.25,
})

hl.monitor({
    output   = "eDP-2",
    mode     = "preferred",
    position = "auto",
    scale    = 1.25,
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "ghostty"
local fileManager = "thunar"
local menu        = "rofi -show drun"
local keys        = home .. "/.config/rofi/launchers/type-1/launcher.sh"
local browser     = "brave"
local mainMod     = "SUPER"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP MANGOHUD MANGOHUD_DLSYM")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP MANGOHUD MANGOHUD_DLSYM")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("waybar -c " .. home .. "/.config/hypr/waybar/config -s " .. home .. "/.config/hypr/waybar/style.css")
    hl.exec_cmd("dunst")
    hl.exec_cmd(home .. "/.config/hypr/scripts/update_notifier.sh")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 || /usr/libexec/polkit-gnome-authentication-agent-1")
    hl.exec_cmd(home .. "/.config/hypr/scripts/wallpaper.sh")
    hl.exec_cmd("cursor-clip --daemon")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("PATH", (os.getenv("PATH") or "") .. ":" .. home .. "/.local/bin")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("MANGOHUD", "1")
hl.env("MANGOHUD_DLSYM", "1")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 20,

        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2.0,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Animation curves
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Animations
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })


-----------------
---- LAYOUTS ----
-----------------

hl.config({
    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        disable_hyprland_logo = true,
        vrr                   = 0,
    },
})


---------------------------
---- INPUTS & GESTURES ----
---------------------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

-- Applications & Menus
hl.bind(mainMod .. " + Q",         hl.dsp.exec_cmd(terminal),                                 { desc = "Terminal" })
hl.bind(mainMod .. " + C",         hl.dsp.window.close(),                                     { desc = "Close Window" })
hl.bind(mainMod .. " + M",         hl.dsp.exit(),                                             { desc = "Quit Hyprland" })
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager),                              { desc = "File Manager" })
hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }),                { desc = "Float Window" })
hl.bind(mainMod .. " + space",     hl.dsp.exec_cmd(home .. "/.config/rofi/launchers/type-1/launcher.sh"), { desc = "Launcher" })
hl.bind(mainMod .. " + D",         hl.dsp.exec_cmd("baobab"),                                 { desc = "Disk Usage" })
hl.bind(mainMod .. " + R",         hl.dsp.exec_cmd(home .. "/.config/rofi/launchers/type-6/launcher.sh"), { desc = "App Launcher" })
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo(),                                    { desc = "Pseudo Tiling" })
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd(browser),                                  { desc = "Web Browser" })
hl.bind(mainMod .. " + ALT + R",   hl.dsp.exec_cmd("rofi -show run"),                         { desc = "Run Command" })
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.reload_config(),                                    { desc = "Reload Config" })
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(home .. "/.config/rofi/powermenu/type-1/powermenu.sh"), { desc = "Power Menu" })

-- Window Focus (Super + Arrow Keys)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }),  { desc = "Focus Left" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { desc = "Focus Right" })
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }),    { desc = "Focus Up" })
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }),  { desc = "Focus Down" })

-- Window Movement (Super + Shift + Arrow Keys)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }),  { desc = "Move Window Left" })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }), { desc = "Move Window Right" })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }),    { desc = "Move Window Up" })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }),  { desc = "Move Window Down" })

-- Fullscreen & Floating Modes
hl.bind(mainMod .. " + F",       hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { desc = "Full Screen" })
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), { desc = "Maximize Window" })
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.float({ action = "toggle" }),                            { desc = "Float Window" })

-- Workspaces 1-10
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }),       { desc = "Go to Workspace " .. i })
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { desc = "Move to Workspace " .. i })
end

-- Workspace Cycling
hl.bind(mainMod .. " + ALT + left",  hl.dsp.focus({ workspace = "e-1" }), { desc = "Previous Workspace" })
hl.bind(mainMod .. " + ALT + right", hl.dsp.focus({ workspace = "e+1" }), { desc = "Next Workspace" })
hl.bind(mainMod .. " + mouse_down",  hl.dsp.focus({ workspace = "e+1" }), { desc = "Next Workspace" })
hl.bind(mainMod .. " + mouse_up",    hl.dsp.focus({ workspace = "e-1" }), { desc = "Previous Workspace" })

-- Special Workspace (Scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"),             { desc = "Magic Workspace" })
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), { desc = "Move to Magic Workspace" })

-- Mouse Drag / Resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Utilities & Helpers
hl.bind(mainMod .. " + L",       hl.dsp.exec_cmd("hyprlock"),                                          { desc = "Lock Screen" })
hl.bind(mainMod .. " + I",       hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/keybinds.sh"),         { desc = "Binds Helper" })
hl.bind(mainMod .. " + Print",   hl.dsp.exec_cmd("grim " .. home .. "/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png"), { desc = "Full Screenshot" })
hl.bind("SHIFT + Print",         hl.dsp.exec_cmd("grim -g \"$(slurp)\" " .. home .. "/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png"), { desc = "Area Screenshot" })
hl.bind("ALT + Print",           hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | tee " .. home .. "/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png | wl-copy"), { desc = "Screenshot to Clipboard" })
hl.bind(mainMod .. " + ALT + V", hl.dsp.exec_cmd("cursor-clip"),                                      { desc = "Clipboard Manager" })
hl.bind(mainMod .. " + ALT + C", hl.dsp.exec_cmd("hyprpicker -a"),                                     { desc = "Color Picker" })
hl.bind(mainMod .. " + X",       hl.dsp.exec_cmd("kitty -e btm"),                                      { desc = "System Monitor" })
hl.bind(mainMod .. " + N",       hl.dsp.exec_cmd("dunstctl close-all"),                                { desc = "Clear Notifications" })
hl.bind(mainMod .. " + F1",      hl.dsp.exec_cmd("pavucontrol"),                                       { desc = "Volume Control GUI" })
hl.bind(mainMod .. " + F2",      hl.dsp.exec_cmd("blueman-manager"),                                   { desc = "Bluetooth Manager" })
hl.bind(mainMod .. " + F3",      hl.dsp.exec_cmd("nm-connection-editor"),                             { desc = "Network Connections" })
hl.bind(mainMod .. " + F12",     hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/toggle_mangohud.sh"),  { desc = "Toggle MangoHud" })
hl.bind(mainMod .. " + G",       hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/toggle_mangohud.sh"),  { desc = "Toggle MangoHud" })

-- Audio & Brightness
hl.bind("F11", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true, desc = "Volume Up" })
hl.bind("F10", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true, desc = "Volume Down" })
hl.bind("F9",  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true, desc = "Mute Toggle" })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true, desc = "Mic Mute" })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true, desc = "Volume Up" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true, desc = "Volume Down" })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true, desc = "Mute Toggle" })

hl.bind("ALT + up",              hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/brightness.sh +"), { repeating = true, desc = "Brightness Up" })
hl.bind("ALT + down",            hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/brightness.sh -"), { repeating = true, desc = "Brightness Down" })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/brightness.sh +"), { repeating = true, desc = "Brightness Up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/brightness.sh -"), { repeating = true, desc = "Brightness Down" })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true, desc = "Next Track" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, desc = "Pause" })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, desc = "Play" })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true, desc = "Previous Track" })
hl.bind("ALT + Q",        hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/wallpaper.sh"), { desc = "Next Wallpaper" })

-- Dynamic Gap Controls
hl.bind(mainMod .. " + CTRL + G", function()
    hl.config({
        general = {
            gaps_in  = 0,
            gaps_out = 0,
        },
    })
end, { desc = "Zero Gaps" })

hl.bind(mainMod .. " + SHIFT + G", function()
    hl.config({
        general = {
            gaps_in  = 5,
            gaps_out = 20,
        },
    })
end, { desc = "Reset Gaps" })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Persistent Workspaces
hl.workspace_rule({ workspace = "1", persistent = true })
hl.workspace_rule({ workspace = "2", persistent = true })
hl.workspace_rule({ workspace = "3", persistent = true })
hl.workspace_rule({ workspace = "4", persistent = true })

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "float-open-file",
    match = { title = "^(Open File)$" },
    float = true,
})

hl.window_rule({
    name  = "float-select-file",
    match = { title = "^(Select a File)$" },
    float = true,
})

hl.window_rule({
    name  = "float-choose",
    match = { title = "^(Choose)$" },
    float = true,
})

hl.window_rule({
    name  = "float-save-as",
    match = { title = "^(Save As)$" },
    float = true,
})

hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = "^(pavucontrol)$" },
    float = true,
})

hl.window_rule({
    name  = "float-blueman-manager",
    match = { class = "^(blueman-manager)$" },
    float = true,
})

hl.window_rule({
    name  = "float-nm-connection-editor",
    match = { class = "^(nm-connection-editor)$" },
    float = true,
})

hl.window_rule({
    name  = "float-polkit-gnome",
    match = { class = "^(polkit-gnome-authentication-agent-1)$" },
    float = true,
})


---------------------
---- LAYER RULES ----
---------------------

hl.layer_rule({
    name  = "dunst-blur",
    match = { namespace = "^(dunst)$" },
    blur  = true,
})
