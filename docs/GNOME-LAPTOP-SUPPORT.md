# GNOME Laptop Support

## Features Added

### 🖥️ **GNOME Desktop Detection**
- Automatic detection of GNOME desktop environment
- Wayland/X11 session type detection
- Optimized configuration for GNOME laptops

### 🔋 **Laptop-Specific Optimizations**
- Battery/power supply detection
- Optional auto-lock disabling for remote control
- GNOME power management integration

### 📦 **Installation Enhancements**
- Pre-installation check for existing Input Leap
- Choice to keep, reinstall, or configure existing installation
- Arch Linux validation
- AUR fallback with yay auto-installation

### ⚙️ **GNOME-Specific Settings**
- X11 backend forcing for better compatibility
- Display environment variables
- GNOME shell extensions integration
- Desktop notifications support

## Usage

The setup script now automatically:

1. **Detects your system:**
   ```
   ✓ GNOME desktop environment detected
   ✓ Laptop system detected  
   ✓ Arch Linux detected
   ```

2. **Checks existing installations:**
   ```
   ? Input Leap already installed via AUR
   Choose: [1] Configure only [2] Reinstall [3] Exit
   ```

3. **Configures GNOME optimizations:**
   ```
   ? Disable auto-lock while using Input Leap? (y/N)
   ✓ GNOME laptop configuration completed
   ```

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
