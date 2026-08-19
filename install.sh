#!/usr/bin/env bash
# ==============================================================================
# Arch Linux Hyprland & Dotfiles Package Installer
# Generated based on your system configuration files
# ==============================================================================

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ------------------------------------------------------------------------------
# Root Check
# ------------------------------------------------------------------------------
if [ "$EUID" -eq 0 ]; then
    log_error "Please do not run this script as root/sudo directly."
    log_error "The script will invoke sudo when needed for pacman, while AUR helpers require non-root execution."
    exit 1
fi

echo -e "${CYAN}"
echo "================================================================="
echo "       Hyprland Desktop Environment Package Installer            "
echo "================================================================="
echo -e "${NC}"

# ------------------------------------------------------------------------------
# Package Lists
# ------------------------------------------------------------------------------

# Official Pacman Packages
PACMAN_PKGS=(
    # --- Desktop Compositor & Core ---
    hyprland
    hyprlock
    hypridle
    hyprpicker
    waybar
    dunst
    rofi
    polkit-gnome
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    qt5-wayland
    qt6-wayland

    # --- Terminals & Shell ---
    ghostty
    kitty
    alacritty
    fish
    starship
    zsh

    # --- Utilities & Media ---
    grim
    slurp
    wl-clipboard
    ddcutil
    brightnessctl
    pavucontrol
    playerctl
    bottom
    btop
    htop
    fastfetch
    mpv
    vlc
    python-pywal
    jq
    python

    # --- CLI Tools & Shell Enhancement ---
    eza
    bat
    ugrep
    expac
    reflector
    meld
    tldr
    tree
    rsync

    # --- File Manager & Graphics ---
    thunar
    tumbler
    ffmpegthumbnailer

    # --- Network & Bluetooth ---
    networkmanager
    network-manager-applet
    bluez
    bluez-utils
    blueman
    wireplumber
    pipewire-pulse

    # --- Fonts ---
    ttf-jetbrains-mono-nerd
    noto-fonts
    noto-fonts-emoji
    noto-fonts-extra
)

# AUR Packages
AUR_PKGS=(
    brave-bin
    awww
    cursor-clip-git
    bibata-cursor-theme
    rofi-power-menu
)

# ------------------------------------------------------------------------------
# AUR Helper Check / Installation
# ------------------------------------------------------------------------------
AUR_HELPER=""
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
else
    log_warn "Neither 'yay' nor 'paru' was found."
    read -p "Would you like to install 'yay' now? (Y/n): " install_yay_choice
    install_yay_choice=${install_yay_choice:-Y}
    if [[ "$install_yay_choice" =~ ^[Yy]$ ]]; then
        log_info "Installing dependencies for building yay..."
        sudo pacman -S --needed --noconfirm base-devel git
        
        BUILD_DIR=$(mktemp -d)
        log_info "Cloning yay repository to ${BUILD_DIR}..."
        git clone https://aur.archlinux.org/yay.git "$BUILD_DIR/yay"
        cd "$BUILD_DIR/yay"
        makepkg -si --noconfirm
        cd - &>/dev/null
        rm -rf "$BUILD_DIR"
        AUR_HELPER="yay"
        log_success "'yay' installed successfully."
    else
        log_error "An AUR helper is required to install AUR packages (${AUR_PKGS[*]})."
    fi
fi

log_info "Detected AUR Helper: ${AUR_HELPER:-None}"

# ------------------------------------------------------------------------------
# Install Official Packages
# ------------------------------------------------------------------------------
log_info "Updating package database..."
sudo pacman -Sy

log_info "Installing official repository packages via pacman..."
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
log_success "Official repository packages installed."

# ------------------------------------------------------------------------------
# Install AUR Packages
# ------------------------------------------------------------------------------
if [ -n "$AUR_HELPER" ]; then
    log_info "Installing AUR packages via ${AUR_HELPER}..."
    $AUR_HELPER -S --needed --noconfirm "${AUR_PKGS[@]}"
    log_success "AUR packages installed."
else
    log_warn "Skipping AUR packages because no AUR helper is installed."
fi

# ------------------------------------------------------------------------------
# Service Configuration & Enablement
# ------------------------------------------------------------------------------
log_info "Enabling systemd services..."

# Bluetooth
if systemctl list-unit-files | grep -q bluetooth.service; then
    sudo systemctl enable --now bluetooth.service || log_warn "Failed to start bluetooth.service"
    log_success "Bluetooth service enabled."
fi

# NetworkManager
if systemctl list-unit-files | grep -q NetworkManager.service; then
    sudo systemctl enable --now NetworkManager.service || log_warn "Failed to start NetworkManager.service"
    log_success "NetworkManager service enabled."
fi

# ------------------------------------------------------------------------------
# Shell Setup (Optional)
# ------------------------------------------------------------------------------
if command -v fish &> /dev/null; then
    CURRENT_SHELL=$(basename "$SHELL")
    if [ "$CURRENT_SHELL" != "fish" ]; then
        read -p "Would you like to set fish as your default shell? (y/N): " set_fish
        if [[ "$set_fish" =~ ^[Yy]$ ]]; then
            FISH_PATH=$(which fish)
            if ! grep -q "$FISH_PATH" /etc/shells; then
                echo "$FISH_PATH" | sudo tee -a /etc/shells
            fi
            chsh -s "$FISH_PATH"
            log_success "Default shell changed to fish."
        fi
    fi
fi

echo -e "${GREEN}"
echo "================================================================="
echo "       Package installation completed successfully!             "
echo "================================================================="
echo -e "${NC}"
