#!/bin/bash

# install_input_leap.sh - Install and configure Input Leap for automatic connection
# Run this script to set up Input Leap client on your laptop

echo "🖱️  Input Leap Installation & Setup"
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}❌ Don't run this script as root! Use your regular user account.${NC}"
   exit 1
fi

# Function to install Input Leap
install_input_leap() {
    echo -e "${BLUE}📦 Installing Input Leap...${NC}"
    
    # Try official package first
    if sudo pacman -S --needed --noconfirm input-leap 2>/dev/null; then
        echo -e "${GREEN}✓ Input Leap installed from official repository${NC}"
        return 0
    fi
    
    # If not available, try AUR
    echo -e "${YELLOW}⚠️  Official package not found, trying AUR...${NC}"
    
    # Check if yay is installed
    if ! command -v yay &> /dev/null; then
        echo -e "${YELLOW}Installing yay AUR helper...${NC}"
        
        # Install base-devel if needed
        sudo pacman -S --needed --noconfirm base-devel git
        
        # Install yay
        temp_dir=$(mktemp -d)
        cd "$temp_dir"
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd "$HOME"
        rm -rf "$temp_dir"
    fi
    
    # Install from AUR
    if yay -S --needed --noconfirm input-leap-git; then
        echo -e "${GREEN}✓ Input Leap installed from AUR${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to install Input Leap${NC}"
        return 1
    fi
}

# Function to setup systemd service
setup_systemd_service() {
    echo -e "${BLUE}⚙️  Setting up systemd user service...${NC}"
    
    # Create systemd user directory if it doesn't exist
    mkdir -p "$HOME/.config/systemd/user"
    
    # Copy service file
    if [ -f "/home/jorge/dotfiles/.config/systemd/user/input-leap.service" ]; then
        cp "/home/jorge/dotfiles/.config/systemd/user/input-leap.service" "$HOME/.config/systemd/user/"
        
        # Update the service file to use correct path
        sed -i "s|%h/dotfiles/scripts/connect_input_leap.sh|$HOME/dotfiles/scripts/connect_input_leap.sh|g" "$HOME/.config/systemd/user/input-leap.service"
        
        # Reload systemd and enable service
        systemctl --user daemon-reload
        
        echo -e "${GREEN}✓ Systemd service configured${NC}"
        echo "To enable auto-start on login:"
        echo "  systemctl --user enable input-leap.service"
        echo "To start now:"
        echo "  systemctl --user start input-leap.service"
    else
        echo -e "${YELLOW}⚠️  Service file not found, creating basic service...${NC}"
        
        cat > "$HOME/.config/systemd/user/input-leap.service" << EOF
[Unit]
Description=Input Leap Client Auto Connect
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=$HOME/dotfiles/scripts/connect_input_leap.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF
        
        systemctl --user daemon-reload
        echo -e "${GREEN}✓ Basic systemd service created${NC}"
    fi
}

# Function to configure Input Leap
configure_input_leap() {
    echo -e "${BLUE}🔧 Configuring Input Leap...${NC}"
    echo ""
    
    # Run the configuration
    /home/jorge/dotfiles/scripts/connect_input_leap.sh config
    
    echo ""
    echo -e "${GREEN}✓ Configuration completed${NC}"
}

# Main installation flow
main() {
    echo "This script will:"
    echo "1. Install Input Leap client"
    echo "2. Set up automatic connection script"
    echo "3. Configure systemd service for auto-start"
    echo "4. Configure server connection"
    echo ""
    
    read -p "Continue? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    
    echo ""
    
    # Step 1: Install Input Leap
    if ! command -v input-leap-client &> /dev/null; then
        install_input_leap || exit 1
    else
        echo -e "${GREEN}✓ Input Leap is already installed${NC}"
    fi
    
    # Step 2: Make script executable
    chmod +x /home/jorge/dotfiles/scripts/connect_input_leap.sh
    echo -e "${GREEN}✓ Connection script is ready${NC}"
    
    # Step 3: Setup systemd service
    setup_systemd_service
    
    # Step 4: Configure server
    configure_input_leap
    
    echo ""
    echo -e "${GREEN}🎉 Input Leap setup completed!${NC}"
    echo ""
    echo "Usage:"
    echo "  leap start     # Start connection"
    echo "  leap stop      # Stop connection"
    echo "  leap status    # Check status"
    echo "  leap config    # Reconfigure server"
    echo ""
    echo "Auto-start options:"
    echo "  systemctl --user enable input-leap.service   # Enable auto-start"
    echo "  systemctl --user start input-leap.service    # Start now"
    echo ""
    echo "Manual usage:"
    echo "  /home/jorge/dotfiles/scripts/connect_input_leap.sh"
}

# Run main function
main
