#!/usr/bin/env bash

# ==============================================================================
# Arch Linux Hyprland & Dotfiles Package Installer
# Robust version:
#   - Installs every missing package individually
#   - Continues when a package fails
#   - Handles official + AUR packages separately
#   - Uses pacman -Syu instead of pacman -Sy
#   - Backs up existing Hyprland configuration
#   - Logs installation results
#   - Prints a final success/failure summary
# ==============================================================================

set -uo pipefail

# ------------------------------------------------------------------------------
# Colors
# ------------------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# ------------------------------------------------------------------------------
# Logging
# ------------------------------------------------------------------------------

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[ OK ]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_section() {
    echo
    echo -e "${CYAN}=================================================================${NC}"
    echo -e "${CYAN} $1${NC}"
    echo -e "${CYAN}=================================================================${NC}"
}

# ------------------------------------------------------------------------------
# Root Check
# ------------------------------------------------------------------------------

if [ "$EUID" -eq 0 ]; then
    log_error "Do not run this script as root."
    log_error "Run it as your normal user. sudo will be requested when needed."
    exit 1
fi

# ------------------------------------------------------------------------------
# Script Location
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.config/hypr"

# ------------------------------------------------------------------------------
# Log File
# ------------------------------------------------------------------------------

LOG_DIR="$HOME/.local/share/hyprland-installer"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/install_$(date +%Y%m%d_%H%M%S).log"

# Send output to terminal AND log file
exec > >(tee -a "$LOG_FILE") 2>&1

# ------------------------------------------------------------------------------
# Header
# ------------------------------------------------------------------------------

echo
echo -e "${MAGENTA}"
echo "================================================================="
echo "       Hyprland Desktop Environment Package Installer"
echo "================================================================="
echo -e "${NC}"

log_info "Installation log:"
echo "       $LOG_FILE"

# ------------------------------------------------------------------------------
# Package Lists
# ------------------------------------------------------------------------------

PACMAN_PKGS=(

    # --------------------------------------------------------------------------
    # Desktop / Hyprland
    # --------------------------------------------------------------------------

    hyprland
    hyprlock
    hypridle
    hyprpicker
    waybar
    dunst
    rofi-wayland
    polkit-gnome
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    qt5-wayland
    qt6-wayland

    # --------------------------------------------------------------------------
    # Terminals / Shell
    # --------------------------------------------------------------------------

    ghostty
    kitty
    alacritty
    fish
    starship
    zsh

    # --------------------------------------------------------------------------
    # Utilities / Media
    # --------------------------------------------------------------------------

    grim
    slurp
    wl-clipboard
    ddcutil
    brightnessctl
    pavucontrol
    playerctl
    bottom
    htop
    lm_sensors
    fastfetch
    mpv
    vlc
    python-pywal
    jq
    python

    # --------------------------------------------------------------------------
    # CLI Tools
    # --------------------------------------------------------------------------

    eza
    bat
    ugrep
    expac
    reflector
    meld
    tree
    rsync

    # --------------------------------------------------------------------------
    # File Manager / Graphics
    # --------------------------------------------------------------------------

    thunar
    tumbler
    ffmpegthumbnailer

    # --------------------------------------------------------------------------
    # Network / Bluetooth / Audio
    # --------------------------------------------------------------------------

    networkmanager
    network-manager-applet
    bluez
    bluez-utils
    blueman
    wireplumber
    pipewire-pulse

    # --------------------------------------------------------------------------
    # Fonts
    # --------------------------------------------------------------------------

    ttf-jetbrains-mono-nerd
    noto-fonts
    noto-fonts-emoji
    noto-fonts-extra
)

AUR_PKGS=(
    brave-bin
    awww
    cursor-clip-git
    bibata-cursor-theme
    rofi-power-menu
)

# ------------------------------------------------------------------------------
# Result Arrays
# ------------------------------------------------------------------------------

INSTALLED_PKGS=()
ALREADY_INSTALLED_PKGS=()
FAILED_PKGS=()

INSTALLED_AUR_PKGS=()
ALREADY_INSTALLED_AUR_PKGS=()
FAILED_AUR_PKGS=()

# ------------------------------------------------------------------------------
# Check sudo
# ------------------------------------------------------------------------------

log_section "Checking sudo access"

if ! sudo -v; then
    log_error "sudo authentication failed."
    exit 1
fi

log_success "sudo access confirmed."

# ------------------------------------------------------------------------------
# Hyprland Config Deployment
# ------------------------------------------------------------------------------

log_section "Hyprland Configuration"

if [ "$SCRIPT_DIR" != "$TARGET_DIR" ]; then

    log_info "Installer location:"
    echo "       $SCRIPT_DIR"

    log_info "Hyprland configuration location:"
    echo "       $TARGET_DIR"

    if [ -d "$TARGET_DIR" ]; then

        log_warn "Existing Hyprland configuration found."

        read -rp \
            "Backup existing configuration before deployment? (Y/n): " \
            overwrite_choice

        overwrite_choice="${overwrite_choice:-Y}"

        if [[ "$overwrite_choice" =~ ^[Yy]$ ]]; then

            BACKUP_DIR="${HOME}/.config/hypr_backup_$(date +%Y%m%d_%H%M%S)"

            log_info "Backing up existing Hyprland configuration..."
            mv "$TARGET_DIR" "$BACKUP_DIR"

            log_success "Backup created:"
            echo "       $BACKUP_DIR"

        else

            log_info "Keeping existing Hyprland configuration."

        fi
    fi

    if [ ! -d "$TARGET_DIR" ]; then

        log_info "Deploying Hyprland configuration..."

        mkdir -p "$TARGET_DIR"

        # Copy normal files/directories
        cp -rf "$SCRIPT_DIR"/. "$TARGET_DIR"/

        log_success "Hyprland configuration deployed."

    else

        log_info "Deployment skipped because target already exists."

    fi

else

    log_info "Installer is already inside ~/.config/hypr."
    log_info "Skipping configuration deployment."

fi

# ------------------------------------------------------------------------------
# Make Scripts Executable
# ------------------------------------------------------------------------------

log_section "Setting Script Permissions"

if [ -d "$TARGET_DIR" ]; then

    find "$TARGET_DIR" \
        -type f \
        -name "*.sh" \
        -exec chmod +x {} \; \
        2>/dev/null || true

    log_success "Hyprland shell scripts marked executable."

fi

# ------------------------------------------------------------------------------
# Update System
# ------------------------------------------------------------------------------

log_section "Updating Arch Linux"

log_info "Synchronizing repositories and upgrading the system..."

if sudo pacman -Syu --noconfirm; then
    log_success "System update completed."
else
    log_error "System update failed."
    log_warn "Continuing with package installation..."
fi

# ------------------------------------------------------------------------------
# Check Official Package Availability
# ------------------------------------------------------------------------------

log_section "Checking Official Repository Packages"

AVAILABLE_PKGS=()
UNAVAILABLE_PKGS=()

for pkg in "${PACMAN_PKGS[@]}"; do

    if pacman -Si "$pkg" &>/dev/null; then

        AVAILABLE_PKGS+=("$pkg")
        log_success "$pkg is available."

    else

        UNAVAILABLE_PKGS+=("$pkg")
        log_error "$pkg is NOT available in configured repositories."

    fi

done

# ------------------------------------------------------------------------------
# Install Official Packages
# ------------------------------------------------------------------------------

log_section "Installing Official Repository Packages"

for pkg in "${AVAILABLE_PKGS[@]}"; do

    # Already installed?
    if pacman -Q "$pkg" &>/dev/null; then

        log_info "$pkg is already installed."
        ALREADY_INSTALLED_PKGS+=("$pkg")

        continue
    fi

    log_info "Installing: $pkg"

    if sudo pacman -S --needed --noconfirm "$pkg"; then

        log_success "$pkg installed."
        INSTALLED_PKGS+=("$pkg")

    else

        log_error "Failed to install $pkg."
        FAILED_PKGS+=("$pkg")

    fi

done

# ------------------------------------------------------------------------------
# AUR Helper Detection
# ------------------------------------------------------------------------------

log_section "AUR Helper"

AUR_HELPER=""

if command -v yay &>/dev/null; then

    AUR_HELPER="yay"
    log_success "Found yay."

elif command -v paru &>/dev/null; then

    AUR_HELPER="paru"
    log_success "Found paru."

else

    log_warn "Neither yay nor paru is installed."

    read -rp \
        "Install yay automatically? (Y/n): " \
        install_yay_choice

    install_yay_choice="${install_yay_choice:-Y}"

    if [[ "$install_yay_choice" =~ ^[Yy]$ ]]; then

        log_info "Installing yay dependencies..."

        if sudo pacman -S --needed --noconfirm base-devel git; then

            BUILD_DIR="$(mktemp -d)"

            log_info "Cloning yay..."

            if git clone \
                --depth=1 \
                https://aur.archlinux.org/yay.git \
                "$BUILD_DIR/yay"; then

                cd "$BUILD_DIR/yay"

                if makepkg -si --noconfirm; then
                    AUR_HELPER="yay"
                    log_success "yay installed."
                else
                    log_error "Failed to build/install yay."
                fi

                cd "$SCRIPT_DIR" || true

            else

                log_error "Failed to clone yay repository."

            fi

            rm -rf "$BUILD_DIR"

        else

            log_error "Could not install yay build dependencies."

        fi

    else

        log_warn "AUR installation skipped."

    fi

fi

# ------------------------------------------------------------------------------
# Install AUR Packages
# ------------------------------------------------------------------------------

log_section "Installing AUR Packages"

if [ -n "$AUR_HELPER" ]; then

    log_info "Using AUR helper: $AUR_HELPER"

    for pkg in "${AUR_PKGS[@]}"; do

        if pacman -Q "$pkg" &>/dev/null; then

            log_info "$pkg is already installed."
            ALREADY_INSTALLED_AUR_PKGS+=("$pkg")

            continue
        fi

        log_info "Installing AUR package: $pkg"

        if "$AUR_HELPER" -S --needed --noconfirm "$pkg"; then

            log_success "$pkg installed."
            INSTALLED_AUR_PKGS+=("$pkg")

        else

            log_error "Failed to install AUR package: $pkg"
            FAILED_AUR_PKGS+=("$pkg")

        fi

    done

else

    log_warn "No AUR helper available."
    log_warn "Skipping AUR packages."

    FAILED_AUR_PKGS=("${AUR_PKGS[@]}")

fi

# ------------------------------------------------------------------------------
# Rofi Themes
# ------------------------------------------------------------------------------

log_section "Rofi Themes"

ROFI_CONFIG_DIR="$HOME/.config/rofi"

if [ ! -d "$ROFI_CONFIG_DIR/launchers" ]; then

    log_info "Installing Rofi themes from adi1090x/rofi..."

    ROFI_TMP_DIR="$(mktemp -d)"

    if git clone \
        --depth=1 \
        https://github.com/adi1090x/rofi.git \
        "$ROFI_TMP_DIR"; then

        mkdir -p "$ROFI_CONFIG_DIR"

        if [ -d "$ROFI_TMP_DIR/files" ]; then

            cp -rf "$ROFI_TMP_DIR/files"/. "$ROFI_CONFIG_DIR"/

            log_success "Rofi themes installed."

        else

            log_warn "Rofi repository does not contain expected files directory."

        fi

    else

        log_warn "Failed to clone Rofi themes repository."

    fi

    rm -rf "$ROFI_TMP_DIR"

else

    log_info "Rofi themes already exist."
    log_info "Skipping Rofi theme installation."

fi

# ------------------------------------------------------------------------------
# Rofi Default Theme
# ------------------------------------------------------------------------------

if [ -f "$ROFI_CONFIG_DIR/config.rasi" ]; then

    if ! grep -qF '@theme' "$ROFI_CONFIG_DIR/config.rasi"; then

        echo '@theme "~/.config/rofi/launchers/type-1/style-8.rasi"' \
            >> "$ROFI_CONFIG_DIR/config.rasi"

        log_success "Default Rofi theme configured."

    else

        log_info "Rofi theme already configured."

    fi

fi

# ------------------------------------------------------------------------------
# Rofi Launcher Fix
# ------------------------------------------------------------------------------

ROFI_LAUNCHER="$ROFI_CONFIG_DIR/launchers/type-1/launcher.sh"

if [ -f "$ROFI_LAUNCHER" ]; then

    sed -i 's/-dmenu/-show drun/g' "$ROFI_LAUNCHER"

    chmod +x "$ROFI_LAUNCHER"

    log_success "Rofi launcher configured."

fi

# ------------------------------------------------------------------------------
# Rofi Script Permissions
# ------------------------------------------------------------------------------

if [ -d "$ROFI_CONFIG_DIR" ]; then

    find "$ROFI_CONFIG_DIR" \
        -type f \
        -name "*.sh" \
        -exec chmod +x {} \; \
        2>/dev/null || true

    log_success "Rofi scripts marked executable."

fi

# ------------------------------------------------------------------------------
# Bluetooth Service
# ------------------------------------------------------------------------------

log_section "System Services"

if systemctl list-unit-files \
    bluetooth.service &>/dev/null; then

    if sudo systemctl enable --now bluetooth.service; then
        log_success "Bluetooth service enabled."
    else
        log_warn "Could not start Bluetooth service."
    fi

fi

# ------------------------------------------------------------------------------
# NetworkManager
# ------------------------------------------------------------------------------

if systemctl list-unit-files \
    NetworkManager.service &>/dev/null; then

    if sudo systemctl enable --now NetworkManager.service; then
        log_success "NetworkManager enabled."
    else
        log_warn "Could not start NetworkManager."
    fi

fi

# ------------------------------------------------------------------------------
# PipeWire
# ------------------------------------------------------------------------------

if systemctl --user list-unit-files \
    pipewire.service &>/dev/null; then

    systemctl --user enable --now pipewire.service \
        2>/dev/null || true

    systemctl --user enable --now pipewire-pulse.service \
        2>/dev/null || true

    systemctl --user enable --now wireplumber.service \
        2>/dev/null || true

    log_success "PipeWire/WirePlumber user services configured."

fi

# ------------------------------------------------------------------------------
# Fish Shell
# ------------------------------------------------------------------------------

log_section "Shell Configuration"

if command -v fish &>/dev/null; then

    CURRENT_SHELL="$(basename "${SHELL:-}")"

    if [ "$CURRENT_SHELL" != "fish" ]; then

        read -rp \
            "Set fish as your default shell? (y/N): " \
            set_fish

        if [[ "$set_fish" =~ ^[Yy]$ ]]; then

            FISH_PATH="$(command -v fish)"

            if ! grep -qxF "$FISH_PATH" /etc/shells; then

                echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null

            fi

            if chsh -s "$FISH_PATH"; then
                log_success "Default shell changed to fish."
            else
                log_warn "Could not change default shell."
            fi

        fi

    else

        log_info "Fish is already the default shell."

    fi

fi

# ------------------------------------------------------------------------------
# Refresh Font Cache
# ------------------------------------------------------------------------------

log_section "Font Cache"

if command -v fc-cache &>/dev/null; then

    fc-cache -f &>/dev/null || true

    log_success "Font cache refreshed."

fi

# ------------------------------------------------------------------------------
# Final Summary
# ------------------------------------------------------------------------------

log_section "Installation Summary"

echo
echo -e "${GREEN}Official packages installed:${NC} ${#INSTALLED_PKGS[@]}"
echo -e "${BLUE}Official packages already installed:${NC} ${#ALREADY_INSTALLED_PKGS[@]}"
echo -e "${RED}Official packages failed:${NC} ${#FAILED_PKGS[@]}"
echo -e "${YELLOW}Official packages unavailable:${NC} ${#UNAVAILABLE_PKGS[@]}"

echo
echo -e "${GREEN}AUR packages installed:${NC} ${#INSTALLED_AUR_PKGS[@]}"
echo -e "${BLUE}AUR packages already installed:${NC} ${#ALREADY_INSTALLED_AUR_PKGS[@]}"
echo -e "${RED}AUR packages failed:${NC} ${#FAILED_AUR_PKGS[@]}"

# ------------------------------------------------------------------------------
# Failed Official Packages
# ------------------------------------------------------------------------------

if [ ${#FAILED_PKGS[@]} -gt 0 ]; then

    echo
    echo -e "${RED}Failed official packages:${NC}"

    for pkg in "${FAILED_PKGS[@]}"; do
        echo "  - $pkg"
    done

fi

# ------------------------------------------------------------------------------
# Unavailable Official Packages
# ------------------------------------------------------------------------------

if [ ${#UNAVAILABLE_PKGS[@]} -gt 0 ]; then

    echo
    echo -e "${YELLOW}Unavailable official packages:${NC}"

    for pkg in "${UNAVAILABLE_PKGS[@]}"; do
        echo "  - $pkg"
    done

fi

# ------------------------------------------------------------------------------
# Failed AUR Packages
# ------------------------------------------------------------------------------

if [ ${#FAILED_AUR_PKGS[@]} -gt 0 ]; then

    echo
    echo -e "${RED}Failed AUR packages:${NC}"

    for pkg in "${FAILED_AUR_PKGS[@]}"; do
        echo "  - $pkg"
    done

fi

# ------------------------------------------------------------------------------
# Final Status
# ------------------------------------------------------------------------------

echo
echo -e "${CYAN}=================================================================${NC}"

if [ ${#FAILED_PKGS[@]} -eq 0 ] &&
   [ ${#UNAVAILABLE_PKGS[@]} -eq 0 ] &&
   [ ${#FAILED_AUR_PKGS[@]} -eq 0 ]; then

    echo -e "${GREEN}        Installation completed successfully!${NC}"

else

    echo -e "${YELLOW}        Installation completed with some issues.${NC}"
    echo -e "${YELLOW}        Check the summary above.${NC}"

fi

echo -e "${CYAN}=================================================================${NC}"

echo
log_info "Full installation log:"
echo "       $LOG_FILE"

echo
log_info "You can now reboot and start Hyprland."

echo

