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


# Fool-proof checks
check_environment() {
    # Check if running on Linux
    if [[ "$(uname)" != "Linux" ]]; then
        echo -e "${RED}❌ ERROR: This script only works on Linux!${NC}"
        echo -e "${YELLOW}💡 TIP: If you're on Windows, try WSL2 or use a Linux virtual machine${NC}"
        exit 1
    fi
    
    # Check if we're in the right directory
    if [[ ! -f "$PROJECT_ROOT/setup.sh" ]] || [[ ! -d "$BIN_DIR" ]]; then
        echo -e "${RED}❌ ERROR: You're not in the input-leap directory!${NC}"
        echo -e "${YELLOW}💡 TIP: Navigate to the input-leap folder first:${NC}"
        echo -e "    ${CYAN}cd input-leap${NC}"
        echo -e "    ${CYAN}./setup.sh${NC}"
        exit 1
    fi
    
    # Check if running as root (bad idea)
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}❌ ERROR: Don't run this as root (sudo)!${NC}"
        echo -e "${YELLOW}💡 TIP: Run it as your normal user:${NC}"
        echo -e "    ${CYAN}./setup.sh${NC}"
        echo -e "${YELLOW}    (The script will ask for sudo when needed)${NC}"
        exit 1
    fi
    
    # Check if basic commands exist
    local missing_commands=()
    for cmd in "curl" "wget" "git" "hostname" "ip" "systemctl"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        echo -e "${RED}❌ ERROR: Missing required commands: ${missing_commands[*]}${NC}"
        echo -e "${YELLOW}💡 TIP: Install them first:${NC}"
        
        # Provide specific package recommendations
        local packages_needed=()
        for cmd in "${missing_commands[@]}"; do
            case "$cmd" in
                "hostname") packages_needed+=("inetutils") ;;
                "curl") packages_needed+=("curl") ;;
                "wget") packages_needed+=("wget") ;;
                "git") packages_needed+=("git") ;;
                "ip") packages_needed+=("iproute2") ;;
                "systemctl") packages_needed+=("systemd") ;;
                *) packages_needed+=("$cmd") ;;
            esac
        done
        
        # Remove duplicates
        local unique_packages=($(printf "%s\n" "${packages_needed[@]}" | sort -u))
        
        echo -e "    ${CYAN}sudo pacman -S ${unique_packages[*]}${NC}"
        echo ""
        echo -e "${BLUE}🤖 Want me to install these automatically? [Y/n]${NC} "
        read -r auto_install
        
        case "$auto_install" in
            [nN]|[nN][oO])
                echo -e "${YELLOW}👋 Please install the missing packages and run the script again.${NC}"
                exit 1
                ;;
            *)
                echo -e "${GREEN}🚀 Installing missing packages...${NC}"
                if sudo pacman -S --needed --noconfirm "${unique_packages[@]}"; then
                    echo -e "${GREEN}✅ Successfully installed missing packages!${NC}"
                    echo -e "${BLUE}🔄 Continuing with setup...${NC}"
                    echo ""
                else
                    echo -e "${RED}❌ Failed to install packages. Please install manually and try again.${NC}"
                    exit 1
                fi
                ;;
        esac
    fi
}

# Banner
print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                🖱️  ARCH LINUX INPUT LEAP SETUP 🖱️             ║"
    echo "║                                                               ║"
    echo "║         Streamlined automation for Arch Linux users           ║"
    echo "║            Turn on your client and you're ready!              ║"
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

# Enhanced existing installation detection
check_existing_installation() {
    log_info "Checking for existing Input Leap installation..."
    
    local input_leap_installed=false
    local installation_method=""
    local client_binary=""
    
    # Check for client binary (try multiple names)
    for binary in "input-leapc" "input-leap-client" "synergyc"; do
        if command -v "$binary" &> /dev/null; then
            client_binary="$binary"
            input_leap_installed=true
            break
        fi
    done
    
    if [[ "$input_leap_installed" == true ]]; then
        
        # Try to determine installation method
        if pacman -Qi input-leap &> /dev/null; then
            installation_method="official repository"
        elif pacman -Qi input-leap-git &> /dev/null; then
            installation_method="AUR (input-leap-git)"
        elif which "$client_binary" | grep -q "/usr/local"; then
            installation_method="manual/local installation"
        else
            installation_method="unknown method"
        fi
        
        log_success "Input Leap is already installed via $installation_method"
        log_info "Client binary: $client_binary"
        log_info "Version: $($client_binary --version 2>/dev/null || echo 'Unknown')"
        
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
                log_info "Keeping current installation, skipping re-install. Continuing with configuration and network setup."
                echo -e "${GREEN}👋 Setup aborted by user.${NC}"
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
    
    # Automatically apply Input Leap optimizations
    log_info "Applying Input Leap power optimizations:"
    log_info "  • Disabling screen lock (prevents interruption during remote control)"
    log_info "  • Extending idle timeouts (prevents sleep during remote sessions)"
    log_info "  • Optimizing suspend behavior (maintains network connectivity)"
    
    # Screen lock settings (with error handling)
    gsettings set org.gnome.desktop.screensaver lock-enabled false 2>/dev/null || log_warn "Could not disable screen lock"
    gsettings set org.gnome.desktop.screensaver lock-delay 0 2>/dev/null || log_warn "Could not set lock delay"
    
    # Session idle settings
    gsettings set org.gnome.desktop.session idle-delay 0 2>/dev/null || log_warn "Could not set idle delay"
    
    # Power management settings (with error handling)
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0 2>/dev/null || log_warn "Could not set AC sleep timeout"
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 1800 2>/dev/null || log_warn "Could not set battery sleep timeout"
    gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'interactive' 2>/dev/null || log_warn "Could not set power button action"
    
    # Prevent suspend when lid is closed (for laptops) - with better error handling
    if [[ "$IS_LAPTOP" == true ]]; then
        log_info "Laptop detected - configuring lid close behavior..."
        
        # Check if lid-close settings exist before trying to set them
        if gsettings list-keys org.gnome.settings-daemon.plugins.power 2>/dev/null | grep -q "lid-close-ac-action"; then
            gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action 'nothing' 2>/dev/null || log_warn "Could not set lid-close-ac-action"
            log_info "Configured lid-close on AC power: nothing"
        else
            log_warn "lid-close-ac-action setting not available on this GNOME version"
        fi
        
        if gsettings list-keys org.gnome.settings-daemon.plugins.power 2>/dev/null | grep -q "lid-close-battery-action"; then
            gsettings set org.gnome.settings-daemon.plugins.power lid-close-battery-action 'suspend' 2>/dev/null || log_warn "Could not set lid-close-battery-action"
            log_info "Configured lid-close on battery: suspend"
        else
            log_warn "lid-close-battery-action setting not available on this GNOME version"
        fi
    fi
    
    log_success "GNOME power management optimized for Input Leap"
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
        
        # Configure overview behavior (with error handling)
        gsettings set org.gnome.mutter edge-tiling true 2>/dev/null || log_warn "Could not enable edge tiling"
        gsettings set org.gnome.mutter dynamic-workspaces true 2>/dev/null || log_warn "Could not enable dynamic workspaces"
        gsettings set org.gnome.shell.overrides edge-tiling true 2>/dev/null || log_warn "Could not set shell overrides"
        
        log_success "GNOME Shell integration configured"
    else
        log_info "GNOME Shell not running - skipping shell-specific configuration"
    fi
}

# Configure GNOME accessibility for better Input Leap support
configure_gnome_accessibility() {
    log_info "Configuring GNOME accessibility settings for Input Leap..."
    
    # Automatically enable accessibility features that improve Input Leap compatibility
    log_info "Enabling GNOME accessibility features for better Input Leap support"
    
    # Enable accessibility bus (required for some Input Leap features)
    gsettings set org.gnome.desktop.interface toolkit-accessibility true 2>/dev/null || log_warn "Could not enable toolkit accessibility"
    
    # Configure mouse/pointer settings (with error handling)
    gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false 2>/dev/null || log_warn "Could not configure mouse natural-scroll"
    gsettings set org.gnome.desktop.peripherals.mouse speed 0.0 2>/dev/null || log_warn "Could not configure mouse speed"
    gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'default' 2>/dev/null || log_warn "Could not configure mouse acceleration"
    
    # Configure touchpad (for laptops)
    if [[ "$IS_LAPTOP" == true ]]; then
        log_info "Configuring touchpad settings for laptop..."
        gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true 2>/dev/null || log_warn "Could not enable tap-to-click"
        gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true 2>/dev/null || log_warn "Could not enable two-finger scrolling"
        gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true 2>/dev/null || log_warn "Could not enable natural scroll"
    fi
    
    # Configure keyboard settings
    gsettings set org.gnome.desktop.peripherals.keyboard repeat true 2>/dev/null || log_warn "Could not enable key repeat"
    gsettings set org.gnome.desktop.peripherals.keyboard delay 250 2>/dev/null || log_warn "Could not set keyboard delay"
    gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 30 2>/dev/null || log_warn "Could not set keyboard repeat interval"
    
    log_success "GNOME accessibility configured for Input Leap"
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
    local client_binary=""
    for binary in "input-leapc" "input-leap-client" "synergyc"; do
        if command -v "$binary" &> /dev/null; then
            client_binary="$binary"
            break
        fi
    done
    
    if [[ -n "$client_binary" ]]; then
        log_success "Input Leap is already installed: $client_binary"
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



# Configure network and Input Leap server based on user choice
configure_network_and_server() {
    case "$NETWORK_MODE" in
        "static")
            log_info "🔧 Configuring static Ethernet network with IP: $STATIC_IP..."
            if [[ -x "$BIN_DIR/network-manager" ]]; then
                if "$BIN_DIR/network-manager" static_ip "$STATIC_IP"; then
                    log_success "Static Ethernet configured successfully!"
                    log_info "Your static IP: $STATIC_IP"
                    echo -e "${YELLOW}💡 Configure your server with client IP: $STATIC_IP${NC}"
                else
                    log_warn "Static network setup failed, falling back to dynamic"
                    log_info "You can try manual setup later with: leap network static"
                fi
            fi
            ;;
        "dynamic")
            log_info "🌐 Configuring dynamic network (using existing DHCP)..."
            if [[ -x "$BIN_DIR/network-manager" ]]; then
                if "$BIN_DIR/network-manager" auto; then
                    log_success "Dynamic network configured successfully!"
                    local current_ip=$(hostname -I | awk '{print $1}')
                    log_info "Your current IP: ${current_ip:-'(detecting...)'}"
                    echo -e "${YELLOW}💡 Configure your server with client IP: ${current_ip:-'check with: ip addr'}${NC}"
                else
                    log_warn "Dynamic network setup had issues"
                    log_info "You can try manual setup later with: leap network auto"
                fi
            fi
            ;;
        "skip")
            log_info "⏭️  Skipping network configuration (as requested)"
            echo -e "${CYAN}🔧 Network setup skipped. Configure later with:${NC}"
            echo -e "   ${CYAN}leap network static${NC}  # For static Ethernet"
            echo -e "   ${CYAN}leap network auto${NC}    # For dynamic DHCP"
            echo -e "   ${CYAN}leap network status${NC}  # Check current network"
            ;;
    esac
    
    echo ""
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
    
    # Automatically enable auto-start - it's what most users want
    log_info "Enabling auto-start on login (systemd user service)..."
    systemctl --user enable input-leap.service
    log_success "Auto-start enabled"
    echo ""
    echo -e "${GREEN}✨ Perfect! Input Leap will now start automatically when you log in.${NC}"
    echo -e "${CYAN}To disable: systemctl --user disable input-leap.service${NC}"
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

validate_sudo() {
    if ! sudo -v; then
        log_error "Sudo access is required. Please run the script again and provide your password when prompted."
        exit 1
    fi
    log_success "Sudo access validated."
}

# Confirm settings with the user before executing
confirm_and_execute() {
    echo ""
    echo -e "${PURPLE}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║         PLEASE CONFIRM YOUR SETTINGS         ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════╝${NC}"
    echo ""
    log_info "Network Mode: ${NETWORK_MODE}"
    if [[ "$NETWORK_MODE" == "static" ]]; then
        log_info "Static IP Address: ${STATIC_IP}"
    fi
    
    # Determine the installation action text
    local install_action="Install Input Leap"
    if [[ "${SKIP_INSTALLATION:-false}" == "true" ]]; then
        install_action="Configure existing Input Leap installation"
    fi
    log_info "Installation: ${install_action}"
    
    echo ""
    read -p "Proceed with the setup using these settings? [Y/n]: " confirm
    
    # Default to 'Y' if the user just presses Enter
    case "$confirm" in
        [nN]|[nN][oO])
            echo -e "${RED}Aborting setup at user request.${NC}"
            exit 0
            ;;
        *)
            echo -e "${GREEN}Confirmation received. Starting setup...${NC}"
            ;;
    esac
}


# Choose and configure network setup
choose_network_setup() {
    # This outer loop allows the user to return to the main menu
    while true; do
        echo -e "${PURPLE}🔌 Please choose your network configuration:${NC}"
        echo -e "   ${CYAN}1) Configure a Static IP address${NC}"
        echo -e "   ${CYAN}2) Use Dynamic IP / DHCP (Most common)${NC}"
        echo -e "   ${CYAN}3) Skip network setup${NC}"
        echo ""
        read -p "Enter your choice [1-3]: " choice

        case "$choice" in
            1)
                # --- Static IP Configuration ---
                local ip_entered=false
                while true; do
                    # Add 'back' instruction to the prompt
                    read -p "Enter the static IP (or type 'back' to return): " static_ip_input
                    
                    # Check if the user wants to go back
                    if [[ "$static_ip_input" == "back" ]]; then
                        break # Exit the inner IP input loop
                    fi
                    
                    # Validate the IP address format
                    if [[ "$static_ip_input" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                        export NETWORK_MODE="static"
                        export STATIC_IP="$static_ip_input"
                        echo -e "${GREEN}✅ Static IP set to: $STATIC_IP${NC}"
                        ip_entered=true
                        break # Exit the inner IP input loop
                    else
                        echo -e "${RED}❌ Invalid IP address format. Please try again.${NC}"
                    fi
                done
                
                # If a valid IP was entered, we can exit the main menu loop
                if [[ "$ip_entered" == true ]]; then
                    break
                fi
                ;;
            2)
                # --- Dynamic IP / DHCP Configuration ---
                export NETWORK_MODE="dynamic"
                export STATIC_IP=""
                echo -e "${GREEN}✅ Selected: Dynamic LAN/WiFi networking (DHCP)${NC}"
                break # Exit the main menu loop
                ;;
            3)
                # --- Skip Network Configuration ---
                export NETWORK_MODE="skip"
                export STATIC_IP=""
                echo -e "${GREEN}✅ Selected: Skip network setup${NC}"
                break # Exit the main menu loop
                ;;
            *)
                echo -e "${RED}❌ Invalid choice. Please enter 1, 2, or 3.${NC}"
                ;;
        esac
    done
}


# Main execution
main() {
    print_banner
    log_info "🏗️  Arch Linux Input Leap Auto-Setup Started"
    
    # --- PHASE 1: GATHER INFORMATION ---
    echo -e "${BLUE}[1/3]${NC} Validating sudo access..."
    validate_sudo
    
    echo -e "${BLUE}[2/3]${NC} Choosing network configuration..."
    choose_network_setup
    
    echo -e "${BLUE}[3/3]${NC} Checking for existing installations..."
    detect_system
    check_existing_installation

    # --- PHASE 2: CONFIRMATION ---
    # Ask the user to confirm all choices before proceeding
    confirm_and_execute

    # --- PHASE 3: EXECUTION ---
    # The script will only reach this point if the user confirms
    log_info "🚀 Starting automated setup..."
    
    echo -e "${BLUE}[1/8]${NC} Checking environment and requirements..."
    check_environment
    
    echo -e "${BLUE}[2/8]${NC} Checking permissions..."
    check_root
    
    echo -e "${BLUE}[3/8]${NC} Creating directories..."
    create_directories
    
    echo -e "${BLUE}[4/8]${NC} Installing/Configuring Input Leap..."
    install_input_leap
    
    echo -e "${BLUE}[5/8]${NC} Setting up GNOME integration..."
    setup_gnome_integration
    
    echo -e "${BLUE}[6/8]${NC} Configuring systemd and shell..."
    setup_systemd
    setup_shell_integration
    
    echo -e "${BLUE}[7/8]${NC} Configuring network and server..."
    configure_network_and_server
    
    echo -e "${BLUE}[8/8]${NC} Finalizing setup..."
    test_setup
    enable_autostart
    
    show_usage
    
    echo ""
    echo -e "${GREEN}🎉 Arch Linux Input Leap Setup Complete! 🎉${NC}"
    echo -e "${CYAN}📱 Use 'leap status' to check everything${NC}"
    echo -e "${CYAN}🖱️  Turn on your client and enjoy seamless mouse/keyboard sharing!${NC}"
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
