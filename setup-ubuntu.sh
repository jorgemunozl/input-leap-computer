#!/bin/bash

# Ubuntu Input Leap Auto-Setup (Coming Soon!)
# This is a placeholder for future Ubuntu support

echo "🚧 Ubuntu Support Coming Soon! 🚧"
echo ""
echo "This script will provide Input Leap auto-setup for Ubuntu/Debian systems."
echo ""
echo "Planned features:"
echo "  • APT package management with PPA support"
echo "  • Ubuntu-specific GNOME optimizations" 
echo "  • Snap package detection and handling"
echo "  • WSL compatibility for Windows users"
echo "  • Unity desktop environment support"
echo ""
echo "For now, please:"
echo "  1. Install Input Leap manually: sudo apt install input-leap"
echo "  2. Use the configuration tools from this project"
echo "  3. Adapt the systemd service for your system"
echo ""
echo "Want to contribute Ubuntu support? We'd love your help!"
echo "GitHub: https://github.com/jorgemunozl/input-leap-computer"
echo ""

# Basic detection for Ubuntu systems
if [[ -f "/etc/lsb-release" ]] && grep -q "Ubuntu" /etc/lsb-release; then
    echo "✓ Ubuntu system detected"
    
    # Check if Input Leap is available
    if apt-cache search input-leap | grep -q input-leap; then
        echo "✓ Input Leap is available in repositories"
    else
        echo "⚠️  You may need to add a PPA for Input Leap"
        echo "   Try: sudo add-apt-repository ppa:input-leap-team/ppa"
    fi
    
    # Check desktop environment
    if [[ "$XDG_CURRENT_DESKTOP" == *"ubuntu"* ]] || [[ "$XDG_CURRENT_DESKTOP" == *"Unity"* ]]; then
        echo "✓ Unity desktop detected"
    elif [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
        echo "✓ GNOME desktop detected"
    fi
else
    echo "⚠️  This appears to be a non-Ubuntu system"
fi

echo ""
echo "Stay tuned for full Ubuntu support in upcoming releases! 🚀"
