#!/bin/bash

# --- Configuration ---
STATIC_IP="169.254.135.231/16"
CONFIG_FILE="/etc/systemd/network/25-direct-link.network"

# --- Colors for output ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Main Script ---

# 1. Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This script must be run with sudo or as root.${NC}"
  echo "Please try again with: sudo ./setup_static_ip.sh"
  exit 1
fi

# 2. Find and select the ethernet interface
# Exclude loopback (lo), wireless (wl*), and virtual (v*) devices
interfaces=($(ls /sys/class/net | grep -E '^e'))

if [ ${#interfaces[@]} -eq 0 ]; then
    echo -e "${RED}Error: No wired ethernet interface (like enp3s0 or eth0) found.${NC}"
    exit 1
elif [ ${#interfaces[@]} -eq 1 ]; then
    INTERFACE=${interfaces[0]}
    echo -e "Found ethernet interface: ${GREEN}$INTERFACE${NC}"
else
    echo -e "${YELLOW}Multiple ethernet interfaces found. Please choose one:${NC}"
    select opt in "${interfaces[@]}"; do
        if [ -n "$opt" ]; then
            INTERFACE=$opt
            echo -e "You selected: ${GREEN}$INTERFACE${NC}"
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
fi

# 3. Check for conflicting services (NetworkManager)
if systemctl is-active --quiet NetworkManager; then
    echo -e "\n${YELLOW}Warning: NetworkManager is currently active.${NC}"
    echo "For a static IP with systemd-networkd to work reliably,"
    echo "NetworkManager should be disabled."
    read -p "Do you want to disable NetworkManager? (y/N) " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        echo "Stopping and disabling NetworkManager..."
        systemctl disable --now NetworkManager
        echo -e "${GREEN}NetworkManager disabled.${NC}"
    else
        echo -e "${RED}Aborting. Cannot proceed while NetworkManager is active.${NC}"
        exit 1
    fi
fi

# 4. Create the systemd-networkd configuration file
echo -e "\nCreating configuration file at ${CONFIG_FILE}..."
cat <<EOT > "$CONFIG_FILE"
[Match]
Name=$INTERFACE

[Network]
Address=$STATIC_IP
EOT
echo -e "${GREEN}Configuration file created successfully.${NC}"

# 5. Enable and start systemd-networkd
echo "Enabling and starting systemd-networkd..."
systemctl enable --now systemd-networkd

echo -e "\n${GREEN}Setup Complete!${NC}"
echo "Your interface ${GREEN}$INTERFACE${NC} is now configured with the static IP ${GREEN}$STATIC_IP${NC}."
echo -e "\nTo confirm, run: ${YELLOW}ip addr show $INTERFACE${NC}"
echo -e "\n${YELLOW}IMPORTANT:${NC} Remember to set a static IP on the other laptop (e.g., 169.254.135.232) for them to communicate."

