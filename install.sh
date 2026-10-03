#!/usr/bin/env bash
#
#  macOS-Inspired Hyprland Desktop Setup Script
# Repository: https://github.com/Olinkkt/dotfiles
#

set -eo pipefail

# --- Color formatting ---
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

log_info()    { printf "${BLUE}[INFO]${RESET} %s\n" "$*"; }
log_step()    { printf "\n${BOLD}${CYAN}==>${RESET} ${BOLD}%s${RESET}\n" "$*"; }
log_success() { printf "${GREEN}[✓]${RESET} %s\n" "$*"; }
log_warn()    { printf "${YELLOW}[WARN]${RESET} %s\n" "$*"; }
log_error()   { printf "${RED}[ERROR]${RESET} %s\n" "$*" >&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
NON_INTERACTIVE=false
SKIP_PKGS=false
SKIP_PLUGINS=false

# --- Parse arguments ---
show_help() {
    cat <<EOF
Usage: ./install.sh [OPTIONS]

Options:
  -y, --yes          Run non-interactively (accept all prompts)
  --skip-packages    Skip installing system and AUR packages
  --skip-plugins     Skip installing and compiling hyprpm plugins
  -h, --help         Show this help message
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes)
            NON_INTERACTIVE=true
            shift
            ;;
        --skip-packages)
            SKIP_PKGS=true
            shift
            ;;
        --skip-plugins)
            SKIP_PLUGINS=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            ;;
    esac
done

# --- Pre-flight Checks ---
clear || true
cat << "EOF"
  ███╗   ███╗ █████╗  ██████╗ ██████╗ ███████╗
  ████╗ ████║██╔══██╗██╔════╝██╔═══██╗██╔════╝
  ██╔████╔██║███████║██║     ██║   ██║███████╗
  ██║╚██╔╝██║██╔══██║██║     ██║   ██║╚════██║
  ██║ ╚═╝ ██║██║  ██║╚██████╗╚██████╔╝███████║
  ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝
  Hyprland Desktop Setup for Arch Linux
EOF
printf "\n"

if [ "$(id -u)" -eq 0 ]; then
    log_error "Please run this script as a normal user with sudo privileges, NOT as root."
    exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
    log_error "This script is tailored for Arch Linux and Arch-based distributions (pacman not found)."
    exit 1
fi

if [ "$NON_INTERACTIVE" = false ]; then
    printf "${BOLD}This script will configure your system with the macOS-inspired Hyprland rice.${RESET}\n"
    printf "Existing configuration folders will be safely backed up to:\n  ${CYAN}%s${RESET}\n\n" "$BACKUP_DIR"
    read -rp "Do you wish to proceed? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled by user."
        exit 0
    fi
fi

# --- 1. Detect / Setup AUR Helper ---
AUR_HELPER=""
if [ "$SKIP_PKGS" = false ]; then
    log_step "Checking package managers"
    if command -v yay >/dev/null 2>&1; then
        AUR_HELPER="yay"
        log_success "Found AUR helper: yay"
    elif command -v paru >/dev/null 2>&1; then
        AUR_HELPER="paru"
        log_success "Found AUR helper: paru"
    else
        log_warn "Neither yay nor paru was found."
        if [ "$NON_INTERACTIVE" = false ]; then
            read -rp "Would you like to automatically install 'yay'? [Y/n]: " install_yay_choice
            install_yay_choice=${install_yay_choice:-y}
        else
            install_yay_choice="y"
        fi

        if [[ "$install_yay_choice" =~ ^[Yy]$ ]]; then
            log_info "Installing dependencies for yay..."
            sudo pacman -S --needed --noconfirm base-devel git
            TMP_YAY=$(mktemp -d)
            git clone https://aur.archlinux.org/yay-bin.git "$TMP_YAY" || git clone https://aur.archlinux.org/yay.git "$TMP_YAY"
            (cd "$TMP_YAY" && makepkg -si --noconfirm)
            rm -rf "$TMP_YAY"
            AUR_HELPER="yay"
            log_success "yay installed successfully!"
        else
            log_error "An AUR helper (yay or paru) is required for some packages. Aborting."
            exit 1
        fi
    fi
fi

# --- 2. Install Packages ---
if [ "$SKIP_PKGS" = false ]; then
    log_step "Installing official packages via pacman"
    PACMAN_PKGS=(
        hyprland
        waybar
        hyprpaper
        hyprlock
        hypridle
        wofi
        wlogout
        kitty
        grim
        slurp
        wl-clipboard
        pavucontrol
        networkmanager
        brightnessctl
        inter-font
        ttf-nerd-fonts-symbols
        stow
        curl
        jq
        git
    )

    sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
    log_success "Official repository packages installed."

    log_step "Installing AUR packages via $AUR_HELPER"
    AUR_PKGS=(
        nwg-dock-hyprland
        nwg-look
        whitesur-cursor-theme-git
        whitesur-gtk-theme
        whitesur-icon-theme
    )

    for pkg in "${AUR_PKGS[@]}"; do
        if ! $AUR_HELPER -Q "$pkg" >/dev/null 2>&1; then
            log_info "Installing AUR package: $pkg"
            $AUR_HELPER -S --needed --noconfirm "$pkg" || log_warn "Failed to install $pkg (continuing...)"
        else
            log_success "$pkg is already installed."
        fi
    done
fi

# --- 3. Setup Wallpaper & Helper Scripts ---
log_step "Setting up wallpaper and helper scripts"

mkdir -p "$HOME/Pictures/wallpapers"
mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/.local/bin"

if [ -f "$SCRIPT_DIR/wallpapers/sonoma.jpg" ]; then
    cp -u "$SCRIPT_DIR/wallpapers/sonoma.jpg" "$HOME/Pictures/wallpapers/sonoma.jpg"
    log_success "Wallpaper copied to ~/Pictures/wallpapers/sonoma.jpg"
elif [ ! -f "$HOME/Pictures/wallpapers/sonoma.jpg" ]; then
    log_info "Downloading macOS Sonoma wallpaper..."
    curl -sLo "$HOME/Pictures/wallpapers/sonoma.jpg" "https://raw.githubusercontent.com/Olinkkt/dotfiles/main/wallpapers/sonoma.jpg" || true
fi

# Copy helper scripts to ~/.local/bin
if [ -d "$SCRIPT_DIR/bin/.local/bin" ]; then
    for script in "$SCRIPT_DIR/bin/.local/bin"/*; do
        if [ -f "$script" ]; then
            script_name="$(basename "$script")"
            cp "$script" "$HOME/.local/bin/$script_name"
            chmod +x "$HOME/.local/bin/$script_name"
            log_success "Installed ~/.local/bin/$script_name"
        fi
    done
fi

# Ensure ~/.local/bin is in PATH for current user
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    log_warn "~/.local/bin is not in your current PATH."
    log_info "Make sure to add 'export PATH=\"\$HOME/.local/bin:\$PATH\"' to your ~/.bashrc or ~/.zshrc."
fi

# --- 4. Deploy Dotfiles ---
log_step "Deploying configuration files"

CONFIG_MODULES=(hypr waybar wofi wlogout kitty nwg-dock-hyprland nwg-look)
BACKED_UP_ANY=false

mkdir -p "$HOME/.config"

for mod in "${CONFIG_MODULES[@]}"; do
    TARGET_DIR="$HOME/.config/$mod"
    # Check if target already exists and is not a symlink to our repo
    if [ -d "$TARGET_DIR" ] && [ ! -L "$TARGET_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$TARGET_DIR" "$BACKUP_DIR/$mod"
        BACKED_UP_ANY=true
    fi
done

if [ "$BACKED_UP_ANY" = true ]; then
    log_info "Previous configurations backed up to: $BACKUP_DIR"
fi

# Use stow to link configs
cd "$SCRIPT_DIR"
if command -v stow >/dev/null 2>&1; then
    log_info "Stowing modules: ${CONFIG_MODULES[*]}"
    for mod in "${CONFIG_MODULES[@]}"; do
        stow -R "$mod" || {
            log_warn "Stow had conflicts for $mod. Falling back to direct symlink."
            mkdir -p "$HOME/.config/$mod"
            cp -rsf "$SCRIPT_DIR/$mod/.config/$mod/"* "$HOME/.config/$mod/" 2>/dev/null || true
        }
    done
    # Also stow bin if present
    if [ -d "$SCRIPT_DIR/bin" ]; then
        stow -R bin 2>/dev/null || true
    fi
    log_success "Configurations stowed successfully."
else
    log_info "Stow not available; linking files directly..."
    for mod in "${CONFIG_MODULES[@]}"; do
        mkdir -p "$HOME/.config/$mod"
        ln -sf "$SCRIPT_DIR/$mod/.config/$mod/"* "$HOME/.config/$mod/"
    done
fi

# Ensure hyprpaper path resolves to current user's home
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"
if [ -f "$HYPRPAPER_CONF" ]; then
    # Replace any /home/<username> with actual $HOME
    sed -i -E "s|/home/[^/]+/Pictures/wallpapers/sonoma.jpg|$HOME/Pictures/wallpapers/sonoma.jpg|g" "$HYPRPAPER_CONF"
fi

# --- 5. Configure Hyprland Plugins (hyprpm) ---
if [ "$SKIP_PLUGINS" = false ] && command -v hyprpm >/dev/null 2>&1; then
    log_step "Configuring Hyprland Plugins via hyprpm"
    
    log_info "Updating hyprpm headers and repositories..."
    hyprpm update -n || true

    # 1. hyprbars (window traffic lights)
    if ! hyprpm list 2>/dev/null | grep -q "hyprbars"; then
        log_info "Adding hyprland-plugins (for hyprbars)..."
        hyprpm add https://github.com/hyprwm/hyprland-plugins || true
    fi
    hyprpm enable hyprbars || true

    # 2. dynamic-cursors (macOS-style rotating/smooth cursor)
    if ! hyprpm list 2>/dev/null | grep -q "dynamic-cursors"; then
        log_info "Adding dynamic-cursors..."
        hyprpm add https://github.com/VirtCode/hypr-dynamic-cursors || true
    fi
    hyprpm enable dynamic-cursors || true

    # 3. hyprglass
    if ! hyprpm list 2>/dev/null | grep -q "hyprglass"; then
        log_info "Adding hyprglass..."
        hyprpm add https://github.com/hyprnux/hyprglass || true
    fi

    log_info "Building and reloading plugins..."
    hyprpm reload -n || true
    log_success "Hyprland plugins configured."
fi

# --- 6. Set Default Cursor Theme ---
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
fi

# --- Done! ---
printf "\n"
log_step "✨ Installation Complete!"
cat << EOF

${BOLD}Your macOS-inspired Hyprland environment is ready!${RESET}

${CYAN}Quick Checklist:${RESET}
  • Launch/Reload Hyprland:
      hyprctl reload (if already inside Hyprland)
  • Spotlight Search: Super + D
  • Power Menu:       Super + L
  • Terminal:         Super + Enter
  • Close Window:     Super + Q

If this is your first time using this setup, please log out and log back in
to start Hyprland with all environment variables applied.

Enjoy your new rice! 
EOF
