#!/bin/bash

# GNOME Settings Restoration Script for Input Leap
# Usage: ./restore-gnome-settings.sh
# Description: Restores GNOME settings to their state before Input Leap setup

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

readonly USER_CONFIG="$HOME/.config/input-leap"
readonly BACKUP_DIR="$USER_CONFIG/gnome-backup"

echo -e "${BLUE}🔄 GNOME Settings Restoration${NC}"
echo "================================"

# Check if backup exists
if [[ ! -d "$BACKUP_DIR" ]]; then
    echo -e "${RED}❌ No GNOME settings backup found at $BACKUP_DIR${NC}"
    echo "Backup is created automatically when running Input Leap setup."
    exit 1
fi

echo -e "${YELLOW}⚠️  This will restore your GNOME settings to their state before Input Leap setup.${NC}"
echo ""
echo "The following settings will be restored:"
echo "• Screen lock and screensaver settings"
echo "• Power management settings"
echo "• Session idle timeouts"
echo "• Notification settings"
echo "• Accessibility settings"
echo "• Privacy settings"
echo ""
echo -n "Continue with restoration? (y/N): "
read -r confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Restoration cancelled."
    exit 0
fi

echo ""
echo -e "${BLUE}Restoring GNOME settings...${NC}"

# Function to restore setting if backup exists
restore_setting() {
    local schema="$1"
    local key="$2"
    local backup_file="$3"
    
    if [[ -f "$BACKUP_DIR/$backup_file" ]]; then
        local value=$(cat "$BACKUP_DIR/$backup_file")
        if [[ -n "$value" && "$value" != "No such key" ]]; then
            gsettings set "$schema" "$key" "$value"
            echo "✓ Restored $schema $key = $value"
        fi
    fi
}

# Restore power management settings
echo "• Restoring power management..."
restore_setting "org.gnome.desktop.screensaver" "lock-enabled" "screensaver-lock"
restore_setting "org.gnome.desktop.screensaver" "lock-delay" "screensaver-delay"
restore_setting "org.gnome.desktop.session" "idle-delay" "session-idle"
restore_setting "org.gnome.settings-daemon.plugins.power" "sleep-inactive-ac-timeout" "power-ac-timeout"
restore_setting "org.gnome.settings-daemon.plugins.power" "sleep-inactive-battery-timeout" "power-battery-timeout"

# Restore notification settings
echo "• Restoring notification settings..."
restore_setting "org.gnome.desktop.notifications" "show-banners" "notifications-banners"
restore_setting "org.gnome.desktop.notifications" "show-in-lock-screen" "notifications-lockscreen"

# Restore accessibility settings
echo "• Restoring accessibility settings..."
restore_setting "org.gnome.desktop.a11y.applications" "screen-keyboard-enabled" "a11y-keyboard"
restore_setting "org.gnome.desktop.a11y.applications" "screen-magnifier-enabled" "a11y-magnifier"

# Restore privacy settings
echo "• Restoring privacy settings..."
restore_setting "org.gnome.desktop.privacy" "remember-recent-files" "privacy-recent"
restore_setting "org.gnome.desktop.privacy" "remove-old-temp-files" "privacy-temp"

echo ""
echo -e "${GREEN}✅ GNOME settings restoration completed!${NC}"
echo ""
echo "Additional cleanup options:"
echo "• Remove Input Leap GNOME notification script: rm -f $USER_CONFIG/notify-input-leap.sh"
echo "• Remove backup directory: rm -rf $BACKUP_DIR"
echo "• Keep backups for future reference: Leave files as-is"
echo ""
echo -n "Remove backup files now? (y/N): "
read -r remove_backup

if [[ "$remove_backup" =~ ^[Yy]$ ]]; then
    rm -rf "$BACKUP_DIR"
    rm -f "$USER_CONFIG/notify-input-leap.sh"
    echo -e "${GREEN}✅ Backup files removed${NC}"
else
    echo "Backup files preserved at $BACKUP_DIR"
fi

echo ""
echo -e "${BLUE}Note:${NC} You may need to log out and back in for some changes to take full effect."
