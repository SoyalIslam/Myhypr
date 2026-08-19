# ⚡ Cyberpunk Hyprland Dotfiles

A modern, highly responsive, and automated **Hyprland Wayland Desktop Configuration** built for Arch Linux. Featuring dynamic theme color generation via **Pywal**, custom **Waybar**, **Rofi** application launcher & power menus, and intelligent hardware backlight/DDC brightness controls.

---

## ✨ Features

- **🎨 Dynamic Wallpaper & Pywal Colors**: Automatic color extraction using `pywal` and seamless wallpaper transitions with `awww`.
- **📊 Custom Cyberpunk Waybar**: Clean top bar with live system stats (CPU, RAM, Temp, Network, Bluetooth, Audio, Power status, and Clipboard). Supports live CSS reloading via `SIGUSR2`.
- **🚀 Rofi Application Launcher & Menus**: Pre-configured with **adi1090x Rofi themes**, custom app launcher (`drun`), command runner, and interactive power menu (`SUPER + SHIFT + E`).
- **💡 Smart Brightness Control**: Intelligent multi-device brightness script (`brightness.sh`) that automatically toggles between `brightnessctl` (laptop backlight) and `ddcutil` (external I2C monitor auto-bus detection) with smooth Dunst OSD notifications.
- **🔊 Audio & Media Controls**: Built-in `wpctl` and `playerctl` integration with volume notifications.
- **🛠️ Automated Installation (`install.sh`)**: One-command setup that installs all official Arch packages, AUR dependencies, clones Rofi themes, sets up environment variables, and configures script permissions.

---

## ⌨️ Keybindings Quick Reference

> **Main Key (`$mainMod`)**: `SUPER` (Windows key)

### Application Launchers
| Keybinding | Action |
| :--- | :--- |
| `SUPER` + `Space` / `SUPER` + `D` | Open Rofi App Launcher (`drun`) |
| `SUPER` + `R` | Open Rofi Styled Launcher |
| `SUPER` + `ALT` + `R` | Open Rofi Command Runner (`run`) |
| `SUPER` + `Q` | Launch Terminal (`ghostty`) |
| `SUPER` + `E` | Open File Manager (`thunar`) |
| `SUPER` + `B` | Open Web Browser (`brave`) |
| `SUPER` + `SHIFT` + `E` | Open Rofi Power Menu (Shutdown, Reboot, Logout, Suspend, Lock) |
| `SUPER` + `I` | Show Interactive Keybindings Cheatsheet |

### Window Management
| Keybinding | Action |
| :--- | :--- |
| `SUPER` + `C` | Close Active Window |
| `SUPER` + `V` / `SUPER` + `ALT` + `F` | Toggle Floating Window |
| `SUPER` + `F` | Fullscreen Toggle |
| `SUPER` + `SHIFT` + `F` | Fake Fullscreen |
| `SUPER` + `M` | Exit Hyprland |
| `SUPER` + `Arrow Keys` | Move Focus Left / Right / Up / Down |
| `SUPER` + `SHIFT` + `Arrow Keys` | Move Window Left / Right / Up / Down |
| `SUPER` + `1` – `9` | Switch to Workspace 1 – 9 |
| `SUPER` + `SHIFT` + `1` – `9` | Move Focused Window to Workspace 1 – 9 |

### Utilities & Controls
| Keybinding | Action |
| :--- | :--- |
| `Fn` Brightness / `ALT` + `Up/Down` | Adjust Display Brightness (+5% / -5%) |
| `F11` / `F10` | Volume Up / Volume Down |
| `F9` | Mute Audio Toggle |
| `ALT` + `Q` | Change Wallpaper & Regenerate Pywal Theme |
| `PrintScreen` | Full Screenshot (`grim`) |
| `SHIFT` + `PrintScreen` | Select Region Screenshot (`grim` + `slurp`) |
| `SUPER` + `L` | Lock Screen (`hyprlock`) |

---

## 📦 System Dependencies

### Core Packages (Pacman)
- `hyprland`, `hyprlock`, `hypridle`, `hyprpicker`
- `waybar`, `dunst`, `rofi-wayland`, `polkit-gnome`
- `ghostty`, `kitty`, `alacritty`
- `thunar`, `brightnessctl`, `ddcutil`, `pavucontrol`, `playerctl`
- `python-pywal`, `lm_sensors`, `bottom`, `fastfetch`
- `ttf-jetbrains-mono-nerd`, `noto-fonts`, `noto-fonts-emoji`

### AUR Packages
- `awww` *(Wallpaper daemon)*
- `cursor-clip-git` *(Clipboard daemon)*
- `bibata-cursor-theme`

---

## 🚀 Installation & Setup

1. **Clone the repository anywhere** (e.g. `~/Downloads`, `~/dotfiles`, or `~/.config/hypr`):
   ```bash
   git clone https://github.com/YOUR_USERNAME/hyprland-dotfiles.git hypr-dotfiles
   cd hypr-dotfiles
   ```

2. **Make the installer executable**:
   ```bash
   chmod +x install.sh
   ```

3. **Run the installation script**:
   ```bash
   ./install.sh
   ```

> ℹ️ The installer will automatically:
> - Detect its running location and deploy dotfiles to `~/.config/hypr`.
> - If an existing `~/.config/hypr` directory exists, it prompts for permission to create a backup (`~/.config/hypr_backup_YYYYMMDD_HHMMSS`) and overwrite it.
> - Check for an AUR helper (`yay` or `paru`) and install `yay` if missing.
> - Install all required official Pacman and AUR packages.
> - Clone and configure the **adi1090x Rofi themes** into `~/.config/rofi`.
> - Enable Systemd services (`bluetooth.service`, `NetworkManager.service`).
> - Apply executable permissions (`chmod +x`) to all scripts in `~/.config/hypr` and `~/.config/rofi`.

---

## 🔧 Architecture & Customization

- **Hyprland Config**: [hyprland.conf](file:///home/gaffer/.config/hypr/hyprland.conf)
- **Waybar Configuration**: [waybar/config](file:///home/gaffer/.config/hypr/waybar/config)
- **Waybar Dynamic Stylesheet**: [waybar/style.css](file:///home/gaffer/.config/hypr/waybar/style.css)
- **Rofi Main Configuration**: `~/.config/rofi/config.rasi`
- **Helper Scripts**:
  - `scripts/wallpaper.sh`: Handles wallpaper transitions & dynamic Pywal color generation.
  - `scripts/brightness.sh`: Hardware backlight & DDC I2C bus auto-detection.
  - `scripts/keybinds.sh`: Rofi-based interactive keybinding search menu.
  - `waybar/power-status.sh`: Battery status & desktop power detection.
  - `waybar/temp-status.sh`: Multi-CPU/GPU hardware temperature monitor.

---

## 📄 License

Distributed under the MIT License. Feel free to modify and customize for your own setup!
