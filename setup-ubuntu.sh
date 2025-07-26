#!/bin/bash

# Ubuntu Input Leap Auto-Setup - Full Ubuntu/Debian Support
# Usage: ./setup-ubuntu.sh
# Description: Complete setup of Input Leap with automatic connection on Ubuntu/Debian

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

# System detection flags
DESKTOP_ENV=""
IS_LAPTOP=false
IS_UBUNTU=false
IS_WSL=false
SKIP_INSTALLATION=false

# Validate sudo access early
validate_sudo() {
    echo -e "${BLUE}🔐 Checking sudo access for seamless installation...${NC}"
    
    if ! sudo -v; then
        echo -e "${RED}❌ ERROR: Need sudo access to install packages and configure system${NC}"
        echo -e "${YELLOW}💡 TIP: Enter your password when prompted${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Sudo access validated!${NC}"
}

# Ask user about network preference
choose_network_setup() {
    echo ""
    echo -e "${PURPLE}🌐 Network Setup Choice${NC}"
    echo -e "${YELLOW}Choose your preferred network configuration:${NC}"
    echo ""
    echo -e "${CYAN}1. Static Ethernet (RECOMMENDED)${NC} - Fixed IP on wired connection"
    echo -e "   ${BLUE}→ Most reliable, no DHCP issues, works without router${NC}"
    echo -e "   ${BLUE}→ IP: 169.254.135.230 (link-local, always works)${NC}"
    echo ""
    echo -e "${CYAN}2. Dynamic LAN/WiFi${NC} - Use existing DHCP network"
    echo -e "   ${BLUE}→ Uses your current network (WiFi/Ethernet)${NC}"
    echo -e "   ${BLUE}→ IP changes with DHCP, may need reconfiguration${NC}"
    echo ""
    echo -e "${CYAN}3. Skip Network Setup${NC} - Configure manually later"
    echo -e "   ${BLUE}→ Install only, configure network with 'leap network' commands${NC}"
    echo ""
    
    while true; do
        echo -n -e "${YELLOW}Enter your choice [1/2/3] (default: 1): ${NC}"
        read -r network_choice
        
        # Default to static ethernet
        network_choice=${network_choice:-1}
        
        case "$network_choice" in
            1)
                export NETWORK_MODE="static"
                echo -e "${GREEN}✅ Selected: Static Ethernet with link-local IP${NC}"
                break
                ;;
            2)
                export NETWORK_MODE="dynamic"
                echo -e "${GREEN}✅ Selected: Dynamic LAN/WiFi networking${NC}"
                break
                ;;
            3)
                export NETWORK_MODE="skip"
                echo -e "${GREEN}✅ Selected: Skip network setup (manual configuration)${NC}"
                break
                ;;
            *)
                echo -e "${RED}❌ Invalid choice. Please enter 1, 2, or 3${NC}"
                ;;
        esac
    done
}

# Banner
print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║               🐧 INPUT LEAP SETUP - UBUNTU 🐧                 ║"
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

# Detect Ubuntu/Debian system
detect_system() {
    log_info "Detecting Ubuntu/Debian system configuration..."
    
    # Detect Ubuntu/Debian
    if [[ -f "/etc/lsb-release" ]] && grep -q "Ubuntu" /etc/lsb-release; then
        IS_UBUNTU=true
        local ubuntu_version=$(grep "DISTRIB_RELEASE" /etc/lsb-release | cut -d'=' -f2)
        log_info "Detected Ubuntu $ubuntu_version"
    elif [[ -f "/etc/debian_version" ]]; then
        IS_UBUNTU=true  # Treat Debian as Ubuntu-compatible
        local debian_version=$(cat /etc/debian_version)
        log_info "Detected Debian $debian_version"
    else
        log_error "This script is for Ubuntu/Debian systems only"
        log_info "For Arch Linux, use: ./setup.sh"
        exit 1
    fi
    
    # Detect WSL
    if grep -qi "microsoft" /proc/version 2>/dev/null; then
        IS_WSL=true
        log_info "Detected WSL (Windows Subsystem for Linux)"
    fi
    
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
    elif [[ "$xdg_desktop" == *"Unity"* ]]; then
        DESKTOP_ENV="UNITY"
        log_info "Detected Unity desktop environment"
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
        if dpkg -l input-leap &> /dev/null; then
            installation_method="APT package"
        elif snap list input-leap &> /dev/null 2>&1; then
            installation_method="Snap package"
        elif flatpak list | grep -q input-leap 2>/dev/null; then
            installation_method="Flatpak"
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
    
    # Try APT package first
    if dpkg -l input-leap &> /dev/null; then
        sudo apt remove --purge input-leap -y
        log_success "Removed APT Input Leap package"
    fi
    
    # Try Snap package
    if snap list input-leap &> /dev/null 2>&1; then
        sudo snap remove input-leap
        log_success "Removed Snap Input Leap package"
    fi
    
    # Try Flatpak
    if flatpak list | grep -q input-leap 2>/dev/null; then
        flatpak uninstall input-leap -y
        log_success "Removed Flatpak Input Leap package"
    fi
    
    # Clean up any remaining files
    sudo rm -f /usr/local/bin/input-leap-* 2>/dev/null || true
}

# Enhanced GNOME integration for Ubuntu systems
setup_gnome_integration_ubuntu() {
    # Check for GNOME components availability
    local has_gnome_components=false
    if [[ "$DESKTOP_ENV" == "GNOME" ]] || [[ "$DESKTOP_ENV" == "UNITY" ]] || command -v gsettings &> /dev/null; then
        has_gnome_components=true
    fi
    
    if [[ "$has_gnome_components" == true ]]; then
        log_info "Configuring comprehensive GNOME integration for Ubuntu..."
        log_info "Detected GNOME environment (Desktop: $DESKTOP_ENV)"
        
        # Create GNOME-specific config directory
        mkdir -p "$USER_CONFIG/gnome-backup"
        
        # Enhanced GNOME settings management
        if command -v gsettings &> /dev/null; then
            log_info "Configuring GNOME desktop settings for Input Leap..."
            
            # Backup current GNOME settings
            backup_gnome_settings_ubuntu
            
            # Configure power management
            configure_gnome_power_management_ubuntu
            
            # Setup GNOME notifications
            setup_gnome_notifications_ubuntu
        fi
        
        # Install Ubuntu GNOME dependencies
        install_gnome_dependencies_ubuntu
        
        log_success "Complete GNOME integration configured for Ubuntu"
    else
        log_info "GNOME components not detected - skipping GNOME-specific configuration"
    fi
}

# Backup GNOME settings for Ubuntu
backup_gnome_settings_ubuntu() {
    log_info "Backing up current GNOME settings..."
    
    # Power management settings
    gsettings get org.gnome.desktop.screensaver lock-enabled > "$USER_CONFIG/gnome-backup/screensaver-lock" 2>/dev/null || true
    gsettings get org.gnome.desktop.session idle-delay > "$USER_CONFIG/gnome-backup/session-idle" 2>/dev/null || true
    
    # Unity-specific settings (if applicable)
    if [[ "$DESKTOP_ENV" == "UNITY" ]]; then
        gsettings get com.canonical.Unity.Launcher launcher-position > "$USER_CONFIG/gnome-backup/unity-launcher" 2>/dev/null || true
    fi
    
    log_success "GNOME settings backed up to $USER_CONFIG/gnome-backup/"
}

# Configure GNOME power management for Ubuntu
configure_gnome_power_management_ubuntu() {
    log_info "Configuring GNOME power management for Ubuntu..."
    
    # Automatically apply Input Leap optimizations for Ubuntu
    log_info "Applying Ubuntu GNOME power optimizations for Input Leap:"
    log_info "  • Disabling screen lock (prevents interruption during remote control)"
    log_info "  • Extending idle timeouts (prevents sleep during remote sessions)"
    
    # Screen lock settings
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    gsettings set org.gnome.desktop.session idle-delay 0
    
    # Ubuntu-specific power settings
    if command -v ubuntu-drivers &> /dev/null; then
        log_info "Detected Ubuntu drivers - optimizing power management"
    fi
    
    log_success "Ubuntu GNOME power management optimized for Input Leap"
}

# Setup GNOME notifications for Ubuntu
setup_gnome_notifications_ubuntu() {
    log_info "Setting up GNOME notifications for Ubuntu..."
    
    # Create Ubuntu-specific notification script
    cat > "$USER_CONFIG/notify-input-leap-ubuntu.sh" << 'EOF'
#!/bin/bash
# Ubuntu GNOME notification helper for Input Leap events

notify_connection() {
    local status="$1"
    local server="$2"
    
    case "$status" in
        "connected")
            notify-send -i network-wired -u normal "Input Leap" "Connected to $server" || \
            notify-send -u normal "Input Leap" "Connected to $server"
            ;;
        "disconnected")
            notify-send -i network-offline -u normal "Input Leap" "Disconnected from $server" || \
            notify-send -u normal "Input Leap" "Disconnected from $server"
            ;;
        "error")
            notify-send -i dialog-error -u critical "Input Leap" "Connection error: $server" || \
            notify-send -u critical "Input Leap" "Connection error: $server"
            ;;
    esac
}

# Call function with parameters
notify_connection "$@"
EOF
    
    chmod +x "$USER_CONFIG/notify-input-leap-ubuntu.sh"
    log_success "Ubuntu GNOME notifications configured for Input Leap"
}

# Install Ubuntu GNOME dependencies
install_gnome_dependencies_ubuntu() {
    log_info "Installing Ubuntu GNOME integration packages..."
    
    local ubuntu_packages=(
        "libnotify-bin"               # Desktop notifications
        "gnome-shell-extensions"      # Shell extensions (if available)
        "gnome-tweaks"               # GNOME tweaks tool
        "dconf-editor"               # Settings editor
    )
    
    # Update package list
    sudo apt update
    
    # Install packages that are available
    for package in "${ubuntu_packages[@]}"; do
        if apt-cache show "$package" &>/dev/null; then
            sudo apt install -y "$package" || log_warn "Failed to install $package"
        else
            log_warn "Package $package not available in Ubuntu repositories"
        fi
    done
    
    log_success "Ubuntu GNOME integration packages installed"
}

# Create necessary directories
create_directories() {
    log_info "Creating user directories..."
    mkdir -p "$USER_CONFIG" "$USER_CACHE" "$USER_SYSTEMD"
    log_success "Directories created"
}

# Install Input Leap package for Ubuntu
install_input_leap_ubuntu() {
    if [[ "$SKIP_INSTALLATION" == true ]]; then
        log_info "Skipping Input Leap installation (already installed)"
        return 0
    fi
    
    log_info "Installing Input Leap for Ubuntu..."
    
    # Try different installation methods
    if install_via_apt; then
        log_success "Input Leap installed via APT"
    elif install_via_snap; then
        log_success "Input Leap installed via Snap"
    elif install_via_flatpak; then
        log_success "Input Leap installed via Flatpak"
    else
        log_error "Failed to install Input Leap via any method"
        return 1
    fi
}

# Install via APT
install_via_apt() {
    log_info "Trying APT installation..."
    
    # Update package list
    sudo apt update
    
    # Try to install Input Leap
    if apt-cache show input-leap &>/dev/null; then
        sudo apt install -y input-leap
        return 0
    else
        log_warn "Input Leap not available in default Ubuntu repositories"
        return 1
    fi
}

# Install via Snap
install_via_snap() {
    log_info "Trying Snap installation..."
    
    if command -v snap &>/dev/null; then
        if snap info input-leap &>/dev/null; then
            sudo snap install input-leap
            return 0
        else
            log_warn "Input Leap not available as Snap package"
            return 1
        fi
    else
        log_warn "Snap not available on this system"
        return 1
    fi
}

# Install via Flatpak
install_via_flatpak() {
    log_info "Trying Flatpak installation..."
    
    if command -v flatpak &>/dev/null; then
        # Add Flathub if not already added
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        
        if flatpak search input-leap | grep -q input-leap; then
            flatpak install -y flathub input-leap
            return 0
        else
            log_warn "Input Leap not available as Flatpak"
            return 1
        fi
    else
        log_warn "Flatpak not available on this system"
        return 1
    fi
}

# Setup systemd service (same as Arch version but Ubuntu-adapted)
setup_systemd_ubuntu() {
    log_info "Setting up systemd user service for Ubuntu..."
    
    # Use the same service template but adapt paths
    local service_content=$(cat "$SYSTEMD_DIR/input-leap.service")
    service_content=${service_content//\{\{PROJECT_ROOT\}\}/$PROJECT_ROOT}
    
    # Ubuntu-specific environment variables
    service_content="${service_content}
# Ubuntu-specific environment
Environment=UBUNTU_MENUPROXY=0
Environment=LIBOVERLAY_SCROLLBAR=0"
    
    echo "$service_content" > "$USER_SYSTEMD/input-leap.service"
    
    # Reload and enable service
    systemctl --user daemon-reload
    
    log_success "Systemd service configured for Ubuntu"
}

# Setup shell integration (same as Arch version)
setup_shell_integration_ubuntu() {
    log_info "Setting up shell integration..."
    
    # Add to PATH if not already there
    local bin_path_addition='export PATH="'"$PROJECT_ROOT"'/bin:$PATH"'
    
    if ! grep -q "$PROJECT_ROOT/bin" "$HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$HOME/.bashrc"
        echo "# Input Leap integration" >> "$HOME/.bashrc"
        echo "$bin_path_addition" >> "$HOME/.bashrc"
        log_success "Added Input Leap to PATH in .bashrc"
    else
        log_info "Input Leap already in PATH"
    fi
}

# Main setup function
main() {
    print_banner
    
    log_info "Starting Input Leap setup for Ubuntu/Debian..."
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        log_error "Please don't run this script as root"
        exit 1
    fi
    
    detect_system
    check_existing_installation
    create_directories
    install_input_leap_ubuntu
    setup_gnome_integration_ubuntu
    setup_systemd_ubuntu
    setup_shell_integration_ubuntu
    
    # Configure server (reuse from main project)
    if [[ -x "$BIN_DIR/input-leap-manager" ]]; then
        log_info "Configuring Input Leap server connection..."
        "$BIN_DIR/input-leap-manager" config
    fi
    
    log_success "Input Leap setup completed for Ubuntu!"
    echo ""
    echo -e "${GREEN}🎉 Input Leap is ready! Turn on your client and enjoy seamless mouse/keyboard sharing! 🎉${NC}"
    echo ""
    echo "Usage:"
    echo "  leap start      # Start Input Leap"
    echo "  leap stop       # Stop Input Leap"
    echo "  leap status     # Check status"
    echo "  leap config     # Reconfigure server"
    echo ""
    echo "Auto-start:"
    echo "  systemctl --user enable input-leap.service"
}

# Run main function
main "$@"
