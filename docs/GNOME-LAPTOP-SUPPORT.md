# 🖥️ Complete GNOME Support for Input Leap

This document provides comprehensive information about Input Leap's full GNOME desktop environment integration for all systems (laptops and desktops).

## ✨ Comprehensive GNOME Features

### 🔋 **Power Management Excellence**
- **Smart screen lock handling** - Automatic disable/enable based on Input Leap usage
- **Intelligent idle timeout management** - Prevents unwanted sleep during remote sessions  
- **Battery-aware power profiles** - Different settings for AC vs battery power
- **Lid close behavior optimization** - Laptop-specific suspend management
- **Automatic power button configuration** - Interactive power control

### � **Native Desktop Notifications**
- **Connection status notifications** - Visual feedback for all connection events
- **Custom notification icons** - Appropriate icons for different connection states
- **GNOME notification center integration** - Full compatibility with GNOME's notification system
- **Smart notification timing** - Non-intrusive notification behavior
- **Error notification system** - Clear alerts for connection problems

### ⚙️ **Advanced GNOME Shell Integration**
- **Extension compatibility** - Works seamlessly with popular GNOME extensions
- **Shell behavior optimization** - Enhanced window management for remote control
- **Overview and activities optimization** - Improved workspace switching
- **Dash-to-dock integration** - Optimized panel behavior during remote sessions
- **Dynamic workspace support** - Proper workspace handling across devices

### 🔧 **Accessibility & Input Optimization**
- **Accessibility bus integration** - Full support for assistive technologies
- **Mouse and touchpad configuration** - Optimized pointer behavior
- **Keyboard repeat rate optimization** - Consistent typing experience
- **Natural scrolling configuration** - Proper scroll direction handling
- **Multi-touch gesture support** - Enhanced touchpad functionality

### 🎛️ **Session & Environment Management**
- **XDG portal integration** - Proper desktop portal support
- **Environment variable optimization** - Correct X11/Wayland backend selection
- **Session type detection** - Automatic X11 preference for compatibility
- **GNOME keyring integration** - Secure credential management
- **Virtual filesystem support** - Enhanced file sharing capabilities

### 🔒 **Privacy & Security Integration**
- **Recent files management** - Privacy-aware file history handling
- **Temporary file cleanup** - Automatic cleanup of Input Leap temporary files
- **Search provider configuration** - Optimized desktop search behavior
- **Background app management** - Minimal resource usage

## 🚀 Full GNOME Setup Process

### Automatic GNOME Detection
The setup script automatically detects GNOME environments and components:

```bash
./setup.sh
```

**What gets detected:**
- Full GNOME desktop environment
- GNOME components in mixed environments (e.g., Openbox + GNOME)
- GNOME Shell availability
- gsettings utility presence
- GNOME session management

### Interactive Configuration Options

During setup, you'll be prompted for GNOME-specific optimizations:

#### 1. **Power Management Configuration**
```
GNOME Power Management Configuration:
Input Leap works best with optimized power settings.

Recommended optimizations:
1. Disable automatic screen lock (prevents interruption during remote control)
2. Extend idle timeouts (prevents sleep during remote sessions)  
3. Optimize suspend behavior (maintains network connectivity)

Apply GNOME power optimizations? (Y/n):
```

#### 2. **Accessibility Features**
```
Enable GNOME accessibility features for better Input Leap support? (Y/n):
```

### Comprehensive Package Installation

The setup automatically installs essential GNOME integration packages:

**Core Packages:**
- `libnotify` - Desktop notifications
- `gnome-shell-extensions` - Shell extensions support
- `gnome-tweaks` - Advanced GNOME configuration
- `dconf-editor` - Settings editor

**Integration Packages:**
- `gnome-control-center` - Settings panel
- `gnome-system-monitor` - System monitoring
- `gnome-session` - Session management
- `gnome-settings-daemon` - Settings daemon

**Support Packages:**
- `gvfs` + `gvfs-mtp` - Virtual filesystem
- `xdg-desktop-portal-gnome` - Desktop portal
- `gnome-keyring` - Keyring management

## 🔧 Settings Management & Restoration

### Automatic Backup System
Before applying any changes, Input Leap creates comprehensive backups:

**Backup Location:** `~/.config/input-leap/gnome-backup/`

### Settings Restoration
To restore your original GNOME settings:

```bash
./bin/restore-gnome-settings.sh
```

### Manual GNOME Commands
```bash
# View current optimizations
gsettings get org.gnome.desktop.screensaver lock-enabled
gsettings get org.gnome.desktop.session idle-delay

# Manual restoration
gsettings set org.gnome.desktop.screensaver lock-enabled true
gsettings set org.gnome.desktop.session idle-delay 300
```

---

**🎉 Complete GNOME integration makes Input Leap a first-class GNOME citizen!**

## Manual GNOME Setup

If you need to manually configure GNOME settings:

```bash
# Disable screen lock
gsettings set org.gnome.desktop.screensaver lock-enabled false

# Disable idle timeout
gsettings set org.gnome.desktop.session idle-delay 0

# Force X11 backend for better compatibility
export GDK_BACKEND=x11
```

## Troubleshooting GNOME Issues

### Wayland Compatibility
If using Wayland, Input Leap may have limited functionality. The setup automatically tries to use X11 backend.

### Screen Lock Issues
If the laptop keeps locking during remote control, run:
```bash
./setup.sh
# Choose GNOME optimizations when prompted
```

### Permission Issues
Ensure your user is in the `input` group:
```bash
sudo usermod -a -G input $USER
# Logout and login again
```
