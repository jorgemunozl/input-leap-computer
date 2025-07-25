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

# Create necessary directories
create_directories() {
    log_info "Creating user directories..."
    mkdir -p "$USER_CONFIG" "$USER_CACHE" "$USER_SYSTEMD"
    log_success "Directories created"
}

# Install Input Leap package
install_input_leap() {
    log_info "Installing Input Leap..."
    
    if command -v input-leap-client &> /dev/null; then
        log_success "Input Leap is already installed"
        return 0
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
    create_directories
    install_input_leap
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
