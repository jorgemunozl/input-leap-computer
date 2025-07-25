#!/bin/bash

# Input Leap Auto-Setup - One command to rule them all!
# Usage: ./setup.sh
# Description: Complete setup of Input Leap with automatic connection on startup

set -euo pipefail

# Colors for beautiful output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Project paths
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BIN_DIR="$PROJECT_ROOT/bin"
readonly CONFIG_DIR="$PROJECT_ROOT/config"
readonly SYSTEMD_DIR="$PROJECT_ROOT/systemd"

# User paths
readonly USER_CONFIG="$HOME/.config/input-leap"
readonly USER_CACHE="$HOME/.cache/input-leap"
readonly USER_SYSTEMD="$HOME/.config/systemd/user"

# Banner
print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    🖱️  INPUT LEAP SETUP 🖱️                     ║"
    echo "║                                                               ║"
    echo "║           Turn on your client and Input Leap is ready!       ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Logging
log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Don't run this script as root! Use your regular user account."
        exit 1
    fi
}

# Detect system information
detect_system() {
    log_info "Detecting system configuration..."
    
    # Detect desktop environment - safely handle unset variables
    local xdg_desktop="${XDG_CURRENT_DESKTOP:-}"
    local desktop_session="${DESKTOP_SESSION:-}"
    
    if [[ "$xdg_desktop" == *"GNOME"* ]] || [[ "$desktop_session" == *"gnome"* ]]; then
        DESKTOP_ENV="GNOME"
        log_info "Detected GNOME desktop environment"
    elif [[ "$xdg_desktop" == *"KDE"* ]]; then
        DESKTOP_ENV="KDE"
        log_info "Detected KDE desktop environment"
    elif [[ "$xdg_desktop" == *"XFCE"* ]]; then
        DESKTOP_ENV="XFCE"
        log_info "Detected XFCE desktop environment"
    else
        DESKTOP_ENV="OTHER"
        log_info "Desktop environment: ${xdg_desktop:-Unknown}"
    fi
    
    # Detect if laptop
    if [[ -d "/proc/acpi/battery" ]] || [[ -n "$(ls /sys/class/power_supply/BAT* 2>/dev/null)" ]]; then
        IS_LAPTOP=true
        log_info "Detected laptop system"
    else
        IS_LAPTOP=false
        log_info "Detected desktop system"
    fi
    
    # Detect Arch Linux
    if [[ -f "/etc/arch-release" ]] || command -v pacman &> /dev/null; then
        IS_ARCH=true
        log_info "Detected Arch Linux"
    else
        IS_ARCH=false
        log_warn "Non-Arch system detected - some features may not work"
    fi
}

# Check existing Input Leap installation
check_existing_installation() {
    log_info "Checking for existing Input Leap installation..."
    
    local input_leap_installed=false
    local installation_method=""
    
    # Check if input-leap-client exists
    if command -v input-leap-client &> /dev/null; then
        input_leap_installed=true
        
        # Try to determine installation method
        if pacman -Qi input-leap &> /dev/null; then
            installation_method="official repository"
        elif pacman -Qi input-leap-git &> /dev/null; then
            installation_method="AUR (input-leap-git)"
        elif which input-leap-client | grep -q "/usr/local"; then
            installation_method="manual/local installation"
        else
            installation_method="unknown method"
        fi
        
        log_success "Input Leap is already installed via $installation_method"
        log_info "Version: $(input-leap-client --version 2>/dev/null || echo 'Unknown')"
        
        echo ""
        echo "Input Leap is already installed. What would you like to do?"
        echo "1) Continue with configuration setup only"
        echo "2) Reinstall Input Leap (will remove current installation)"
        echo "3) Exit and keep current installation"
        echo ""
        echo -n "Choose option [1-3]: "
        read -r choice
        
        case "$choice" in
            1)
                log_info "Continuing with configuration setup only..."
                SKIP_INSTALLATION=true
                ;;
            2)
                log_info "Will reinstall Input Leap..."
                remove_existing_installation
                SKIP_INSTALLATION=false
                ;;
            3)
                log_info "Exiting setup. Current installation preserved."
                exit 0
                ;;
            *)
                log_info "Invalid choice. Continuing with configuration setup only..."
                SKIP_INSTALLATION=true
                ;;
        esac
    else
        log_info "No existing Input Leap installation found"
        SKIP_INSTALLATION=false
    fi
}

# Remove existing installation
remove_existing_installation() {
    log_info "Removing existing Input Leap installation..."
    
    # Try official package first
    if pacman -Qi input-leap &> /dev/null; then
        sudo pacman -Rns input-leap --noconfirm
        log_success "Removed official Input Leap package"
    fi
    
    # Try AUR package
    if pacman -Qi input-leap-git &> /dev/null; then
        if command -v yay &> /dev/null; then
            yay -Rns input-leap-git --noconfirm
        else
            sudo pacman -Rns input-leap-git --noconfirm
        fi
        log_success "Removed AUR Input Leap package"
    fi
    
    # Clean up any remaining files
    sudo rm -f /usr/local/bin/input-leap-* 2>/dev/null || true
}

# Enhanced GNOME integration for all systems
setup_gnome_integration() {
    # Check for GNOME components availability
    local has_gnome_components=false
    if [[ "$DESKTOP_ENV" == "GNOME" ]] || command -v gsettings &> /dev/null; then
        has_gnome_components=true
    fi
    
    if [[ "$has_gnome_components" == true ]]; then
        log_info "Configuring comprehensive GNOME integration..."
        log_info "Detected GNOME environment (Desktop: $DESKTOP_ENV)"
        
        # Create GNOME-specific config directory
        mkdir -p "$USER_CONFIG/gnome-backup"
        
        # Enhanced GNOME settings management
        if command -v gsettings &> /dev/null; then
            log_info "Configuring GNOME desktop settings for Input Leap..."
            
            # Backup current GNOME settings
            backup_gnome_settings
            
            # Configure power management for both laptop and desktop
            configure_gnome_power_management
            
            # Setup GNOME shell integration
            setup_gnome_shell_integration
            
            # Configure GNOME input/accessibility settings
            configure_gnome_accessibility
            
            # Setup GNOME notifications
            setup_gnome_notifications
            
            # Configure GNOME session management
            configure_gnome_session
        fi
        
        # Install comprehensive GNOME dependencies
        install_gnome_dependencies
        
        # Setup GNOME-specific service configuration
        setup_gnome_service_config
        
        log_success "Complete GNOME integration configured"
    else
        log_info "GNOME components not detected - skipping GNOME-specific configuration"
    fi
}

# Backup current GNOME settings
backup_gnome_settings() {
    log_info "Backing up current GNOME settings..."
    
    # Power management settings
    gsettings get org.gnome.desktop.screensaver lock-enabled > "$USER_CONFIG/gnome-backup/screensaver-lock" 2>/dev/null || true
    gsettings get org.gnome.desktop.screensaver lock-delay > "$USER_CONFIG/gnome-backup/screensaver-delay" 2>/dev/null || true
    gsettings get org.gnome.desktop.session idle-delay > "$USER_CONFIG/gnome-backup/session-idle" 2>/dev/null || true
    gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout > "$USER_CONFIG/gnome-backup/power-ac-timeout" 2>/dev/null || true
    gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout > "$USER_CONFIG/gnome-backup/power-battery-timeout" 2>/dev/null || true
    
    # Desktop settings
    gsettings get org.gnome.desktop.notifications show-banners > "$USER_CONFIG/gnome-backup/notifications-banners" 2>/dev/null || true
    gsettings get org.gnome.desktop.notifications show-in-lock-screen > "$USER_CONFIG/gnome-backup/notifications-lockscreen" 2>/dev/null || true
    
    # Accessibility settings
    gsettings get org.gnome.desktop.a11y.applications screen-keyboard-enabled > "$USER_CONFIG/gnome-backup/a11y-keyboard" 2>/dev/null || true
    gsettings get org.gnome.desktop.a11y.applications screen-magnifier-enabled > "$USER_CONFIG/gnome-backup/a11y-magnifier" 2>/dev/null || true
    
    # Privacy settings
    gsettings get org.gnome.desktop.privacy remember-recent-files > "$USER_CONFIG/gnome-backup/privacy-recent" 2>/dev/null || true
    gsettings get org.gnome.desktop.privacy remove-old-temp-files > "$USER_CONFIG/gnome-backup/privacy-temp" 2>/dev/null || true
    
    log_success "GNOME settings backed up to $USER_CONFIG/gnome-backup/"
}

# Configure GNOME power management
configure_gnome_power_management() {
    log_info "Configuring GNOME power management for Input Leap..."
    
    echo ""
    echo "GNOME Power Management Configuration:"
    echo "Input Leap works best with optimized power settings."
    echo ""
    echo "Recommended optimizations:"
    echo "1. Disable automatic screen lock (prevents interruption during remote control)"
    echo "2. Extend idle timeouts (prevents sleep during remote sessions)"
    echo "3. Optimize suspend behavior (maintains network connectivity)"
    echo ""
    echo -n "Apply GNOME power optimizations? (Y/n): "
    read -r apply_power_opts
    
    if [[ ! "$apply_power_opts" =~ ^[Nn]$ ]]; then
        # Screen lock settings
        gsettings set org.gnome.desktop.screensaver lock-enabled false
        gsettings set org.gnome.desktop.screensaver lock-delay 0
        
        # Session idle settings
        gsettings set org.gnome.desktop.session idle-delay 0
        
        # Power management settings
        gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
        gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 1800  # 30 min on battery
        gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'interactive'
        
        # Prevent suspend when lid is closed (for laptops)
        if [[ "$IS_LAPTOP" == true ]]; then
            gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action 'nothing'
            gsettings set org.gnome.settings-daemon.plugins.power lid-close-battery-action 'suspend'
        fi
        
        log_success "GNOME power management optimized for Input Leap"
    fi
}

# Setup GNOME Shell integration
setup_gnome_shell_integration() {
    log_info "Setting up GNOME Shell integration..."
    
    # Check if GNOME Shell is running
    if pgrep -x gnome-shell > /dev/null; then
        log_info "GNOME Shell detected - configuring extensions and integration"
        
        # Enable useful extensions for Input Leap (if available)
        local extensions=(
            "system-monitor@paradoxxx.zero.gmail.com"
            "dash-to-dock@micxgx.gmail.com"
            "topicons-plus@gnome-shell-extensions.gcampax.github.com"
        )
        
        for ext in "${extensions[@]}"; do
            if [[ -d "$HOME/.local/share/gnome-shell/extensions/$ext" ]] || [[ -d "/usr/share/gnome-shell/extensions/$ext" ]]; then
                gnome-extensions enable "$ext" 2>/dev/null || true
                log_info "Enabled GNOME extension: $ext"
            fi
        done
        
        # Configure shell behavior
        gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-overview' 2>/dev/null || true
        gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'cycle-windows' 2>/dev/null || true
        
        # Configure overview behavior
        gsettings set org.gnome.mutter edge-tiling true
        gsettings set org.gnome.mutter dynamic-workspaces true
        gsettings set org.gnome.shell.overrides edge-tiling true
        
        log_success "GNOME Shell integration configured"
    else
        log_info "GNOME Shell not running - skipping shell-specific configuration"
    fi
}

# Configure GNOME accessibility for better Input Leap support
configure_gnome_accessibility() {
    log_info "Configuring GNOME accessibility settings..."
    
    echo ""
    echo -n "Enable GNOME accessibility features for better Input Leap support? (Y/n): "
    read -r enable_a11y
    
    if [[ ! "$enable_a11y" =~ ^[Nn]$ ]]; then
        # Enable accessibility bus (required for some Input Leap features)
        gsettings set org.gnome.desktop.interface toolkit-accessibility true
        
        # Configure mouse/pointer settings
        gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false
        gsettings set org.gnome.desktop.peripherals.mouse speed 0.0
        gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'default'
        
        # Configure touchpad (for laptops)
        if [[ "$IS_LAPTOP" == true ]]; then
            gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
            gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true
            gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
        fi
        
        # Configure keyboard settings
        gsettings set org.gnome.desktop.peripherals.keyboard repeat true
        gsettings set org.gnome.desktop.peripherals.keyboard delay 250
        gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 30
        
        log_success "GNOME accessibility configured for Input Leap"
    fi
}

# Setup GNOME notifications for Input Leap
setup_gnome_notifications() {
    log_info "Setting up GNOME notifications for Input Leap..."
    
    # Configure notification settings
    gsettings set org.gnome.desktop.notifications show-banners true
    gsettings set org.gnome.desktop.notifications show-in-lock-screen false
    
    # Create notification script for Input Leap events
    cat > "$USER_CONFIG/notify-input-leap.sh" << 'EOF'
#!/bin/bash
# GNOME notification helper for Input Leap events

notify_connection() {
    local status="$1"
    local server="$2"
    
    case "$status" in
        "connected")
            notify-send -i network-wireless -u normal "Input Leap" "Connected to $server"
            ;;
        "disconnected")
            notify-send -i network-offline -u normal "Input Leap" "Disconnected from $server"
            ;;
        "error")
            notify-send -i dialog-error -u critical "Input Leap" "Connection error: $server"
            ;;
        "reconnecting")
            notify-send -i view-refresh -u normal "Input Leap" "Reconnecting to $server..."
            ;;
    esac
}

# Call function with parameters
notify_connection "$@"
EOF
    
    chmod +x "$USER_CONFIG/notify-input-leap.sh"
    log_success "GNOME notifications configured for Input Leap"
}

# Configure GNOME session management
configure_gnome_session() {
    log_info "Configuring GNOME session management..."
    
    # Privacy settings for better Input Leap performance
    gsettings set org.gnome.desktop.privacy remember-recent-files false
    gsettings set org.gnome.desktop.privacy remove-old-temp-files true
    gsettings set org.gnome.desktop.privacy remove-old-trash-files true
    
    # Search settings
    gsettings set org.gnome.desktop.search-providers disable-external true
    
    # Background apps
    gsettings set org.gnome.desktop.background show-desktop-icons false
    
    log_success "GNOME session optimized for Input Leap"
}

# Install comprehensive GNOME dependencies
install_gnome_dependencies() {
    if [[ "$IS_ARCH" == true ]]; then
        log_info "Installing comprehensive GNOME integration packages..."
        
        local gnome_packages=(
            "libnotify"                    # Desktop notifications
            "gnome-shell-extensions"       # Shell extensions support
            "gnome-tweaks"                # Advanced GNOME configuration
            "dconf-editor"                # Settings editor
            "gnome-control-center"        # Settings panel
            "gnome-system-monitor"        # System monitoring
            "gnome-session"               # Session management
            "gnome-settings-daemon"       # Settings daemon
            "gvfs"                        # Virtual filesystem
            "gvfs-mtp"                    # MTP support
            "xdg-desktop-portal-gnome"    # Desktop portal
            "gnome-keyring"               # Keyring management
        )
        
        # Try to install packages, but don't fail if some are unavailable
        for package in "${gnome_packages[@]}"; do
            if pacman -Si "$package" &>/dev/null; then
                sudo pacman -S --needed --noconfirm "$package" || log_warn "Failed to install $package"
            else
                log_warn "Package $package not available in repositories"
            fi
        done
        
        log_success "GNOME integration packages installed"
    else
        log_info "Non-Arch system detected - GNOME package installation skipped"
    fi
}

# Setup GNOME-specific service configuration
setup_gnome_service_config() {
    log_info "Setting up GNOME-specific service configuration..."
    
    # Create GNOME-optimized systemd service
    local gnome_service_content="$(cat "$SYSTEMD_DIR/input-leap.service" | sed '
s|Environment=XDG_SESSION_TYPE=x11|Environment=XDG_SESSION_TYPE=x11\nEnvironment=GNOME_DESKTOP_SESSION_ID=this-is-deprecated|
/# GNOME\/Wayland compatibility/a\
# GNOME-specific environment\
Environment=GNOME_SHELL_SESSION_MODE=user\
Environment=XDG_CURRENT_DESKTOP=GNOME\
Environment=DESKTOP_SESSION=gnome
')"
    
    # Write enhanced service file
    echo "$gnome_service_content" > "$USER_SYSTEMD/input-leap.service"
    
    log_success "GNOME-optimized service configuration created"
}

# Create necessary directories
create_directories() {
    log_info "Creating user directories..."
    mkdir -p "$USER_CONFIG" "$USER_CACHE" "$USER_SYSTEMD"
    log_success "Directories created"
}

# Install Input Leap package
install_input_leap() {
    if [[ "$SKIP_INSTALLATION" == true ]]; then
        log_info "Skipping Input Leap installation (already installed)"
        return 0
    fi
    
    log_info "Installing Input Leap..."
    
    # Double-check if it got installed during our process
    if command -v input-leap-client &> /dev/null; then
        log_success "Input Leap is already installed"
        return 0
    fi
    
    # Ensure we're on Arch Linux for our installation method
    if [[ "$IS_ARCH" != true ]]; then
        log_error "This installer is designed for Arch Linux. Please install Input Leap manually."
        log_info "Visit: https://github.com/input-leap/input-leap for installation instructions"
        exit 1
    fi
    
    # Try official package first
    if sudo pacman -S --needed --noconfirm input-leap 2>/dev/null; then
        log_success "Input Leap installed from official repository"
        return 0
    fi
    
    # Fall back to AUR
    log_warn "Official package not found, trying AUR..."
    
    # Install yay if needed
    if ! command -v yay &> /dev/null; then
        log_info "Installing yay AUR helper..."
        sudo pacman -S --needed --noconfirm base-devel git
        
        local temp_dir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
        cd "$temp_dir/yay"
        makepkg -si --noconfirm
        cd "$PROJECT_ROOT"
        rm -rf "$temp_dir"
    fi
    
    if yay -S --needed --noconfirm input-leap-git; then
        log_success "Input Leap installed from AUR"
    else
        log_error "Failed to install Input Leap"
        exit 1
    fi
}

# Setup systemd service
setup_systemd() {
    log_info "Setting up systemd service..."
    
    # Copy service file
    cp "$SYSTEMD_DIR/input-leap.service" "$USER_SYSTEMD/"
    
    # Update paths in service file
    sed -i "s|{{PROJECT_ROOT}}|$PROJECT_ROOT|g" "$USER_SYSTEMD/input-leap.service"
    
    systemctl --user daemon-reload
    log_success "Systemd service configured"
}

# Setup shell integration
setup_shell_integration() {
    log_info "Setting up shell integration..."
    
    # Create leap command symlink (try system-wide first, fall back to user local)
    local leap_cmd="/usr/local/bin/leap"
    local user_bin="$HOME/.local/bin"
    
    if [[ ! -L "$leap_cmd" ]] && [[ ! -f "$leap_cmd" ]]; then
        if sudo ln -sf "$BIN_DIR/leap" "$leap_cmd" 2>/dev/null; then
            log_success "Created system-wide 'leap' command"
        else
            # Fall back to user local bin
            mkdir -p "$user_bin"
            ln -sf "$BIN_DIR/leap" "$user_bin/leap"
            log_success "Created user 'leap' command in ~/.local/bin"
            
            # Add ~/.local/bin to PATH if not already there
            if ! echo "$PATH" | grep -q "$user_bin"; then
                if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
                    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
                    log_info "Added ~/.local/bin to PATH in .bashrc"
                fi
            fi
        fi
    else
        log_success "'leap' command already exists"
    fi
    
    # Add to bashrc if not already there
    local bashrc_line="source \"$CONFIG_DIR/bashrc_integration.sh\""
    if ! grep -q -F "$bashrc_line" "$HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$HOME/.bashrc"
        echo "# Input Leap auto-start" >> "$HOME/.bashrc"
        echo "$bashrc_line" >> "$HOME/.bashrc"
        log_success "Added bashrc integration"
    else
        log_success "Bashrc integration already exists"
    fi
}

# Configure Input Leap server
configure_server() {
    log_info "Configuring Input Leap server connection..."
    "$BIN_DIR/input-leap-manager" config
}

# Test the setup
test_setup() {
    log_info "Testing the setup..."
    
    if "$BIN_DIR/input-leap-manager" test; then
        log_success "Setup test passed!"
    else
        log_warn "Setup test had issues, but installation completed"
    fi
}

# Enable auto-start
enable_autostart() {
    echo ""
    echo -e "${PURPLE}🚀 Setup Complete! 🚀${NC}"
    echo ""
    echo "Would you like to enable auto-start on login? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        systemctl --user enable input-leap.service
        log_success "Auto-start enabled"
        echo ""
        echo -e "${GREEN}✨ Perfect! Input Leap will now start automatically when you log in.${NC}"
    else
        echo ""
        echo "You can enable auto-start later with:"
        echo -e "${CYAN}  systemctl --user enable input-leap.service${NC}"
    fi
}

# Show usage information
show_usage() {
    echo ""
    echo -e "${CYAN}📖 Usage:${NC}"
    echo "  leap start      - Connect to server"
    echo "  leap stop       - Disconnect"
    echo "  leap restart    - Reconnect"
    echo "  leap status     - Check connection"
    echo "  leap config     - Configure server"
    echo "  leap logs       - View logs"
    echo ""
    echo -e "${CYAN}🔧 Management:${NC}"
    echo "  systemctl --user start input-leap.service    - Start service"
    echo "  systemctl --user stop input-leap.service     - Stop service"
    echo "  systemctl --user status input-leap.service   - Check service"
    echo ""
}

# Main execution
main() {
    print_banner
    
    check_root
    detect_system
    check_existing_installation
    create_directories
    install_input_leap
    setup_gnome_integration
    setup_systemd
    setup_shell_integration
    configure_server
    test_setup
    enable_autostart
    show_usage
    
    echo -e "${GREEN}🎉 Input Leap is ready! Turn on your client and enjoy seamless mouse/keyboard sharing! 🎉${NC}"
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
