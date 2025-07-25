# 🖱️ Input Leap Auto-Setup

**Turn on your client and Input Leap is ready!**

A complete, robust automation system for Input Leap client setup and management. One command sets up everything you need for seamless mouse and keyboard sharing between your devices.

## ✨ Features

- 🚀 **One-command setup** - Everything configured automatically
- 🔄 **Auto-connection** - Connects automatically on startup/login
- 🛡️ **Robust error handling** - Graceful failure recovery
- 📊 **Smart status monitoring** - Real-time connection health checks
- 🔧 **Easy management** - Simple commands for all operations
- 📱 **Desktop notifications** - Visual feedback for connection status
- 🎯 **Zero configuration** - Works out of the box after setup
- 🔒 **Safe installation** - Backup and rollback capabilities
- 🖥️ **Complete GNOME support** - Full integration with GNOME desktop environments
- 🔋 **Laptop power management** - Smart handling of auto-lock and power settings
- 📦 **Pre-installation checks** - Detects existing installations safely
- ⚡ **Xorg optimization** - Perfect compatibility with X11 sessions

## 🖥️ Supported Systems

### ✅ **Fully Supported & Optimized**
- **Arch Linux** (official repos + AUR)
  - 🖥️ **GNOME desktop environments** - Complete integration with Xorg
  - 🔧 **KDE, XFCE, and other DEs** - Universal compatibility
  - 💻 **Laptop and desktop systems** - Power management optimization
  - 🎯 **Wayland and X11 sessions** - Automatic detection and optimization
  - ⚡ **Xorg services** - Perfect X11 compatibility and backend forcing

### 🚧 **Planned Support**
- **Ubuntu/Debian** - Coming soon with GNOME optimizations!
- **Fedora** - Under consideration
- **Other distributions** - Community contributions welcome

> **Note**: Currently provides enterprise-grade support for Arch Linux with complete GNOME/Xorg integration. Ubuntu support is planned for future releases.

## 🚀 Quick Start

### **Arch Linux (Fully Supported)**
```bash
./setup.sh
```

### **Ubuntu/Debian (Coming Soon)**
```bash
./setup-ubuntu.sh  # Placeholder - shows planned features
```

### **Other Distributions**
Check our [contribution guide](#-contributing) to help add support for your distribution!

That's it! The script will:
1. **Detect your system** (Arch Linux, GNOME, laptop/desktop)
2. **Check existing installations** (gives options to keep/reinstall/configure)
3. **Install Input Leap** (from official repos or AUR)
4. **Configure GNOME optimizations** (complete Xorg integration)
5. **Set up server connection** (interactive configuration)
6. **Enable auto-start** (bashrc + systemd service)
7. **Test everything works** (connection validation)
8. **Create convenient commands** (`leap` command)

## 🖥️ **GNOME + Xorg Excellence**

This project provides **enterprise-grade GNOME integration** with complete Xorg optimization:

### ⚡ **Automatic Xorg Optimization**
- **Smart backend detection** - Automatically prefers X11 over Wayland
- **Environment variable configuration** - Sets `GDK_BACKEND=x11` for stability
- **Display management** - Proper DISPLAY and XDG_RUNTIME_DIR handling
- **Session type awareness** - Adapts behavior for Wayland vs X11 sessions

### 🔧 **GNOME Services Integration**
- **Power management** - Intelligent auto-lock and idle timeout handling
- **Desktop notifications** - Native GNOME notification system integration
- **Shell extensions** - Compatible with GNOME extensions ecosystem
- **Settings synchronization** - Backs up and restores GNOME settings safely

### 💻 **Laptop-Specific Features**
- **Battery detection** - Automatically detects laptop vs desktop systems
- **Power optimization** - Prevents sleep/suspend during remote sessions
- **Screen lock management** - Optional disabling for uninterrupted remote control
- **Thermal awareness** - Respects laptop power profiles

## 🎮 Usage

### Command Line Interface
```bash
# Simple leap commands
leap start      # Connect to server
leap stop       # Disconnect  
leap restart    # Reconnect
leap status     # Check connection status
leap config     # Configure/reconfigure server
leap test       # Test server connection
leap logs       # View client logs
```

### Automatic Operation
- **On login**: Automatically connects via `.bashrc` integration
- **On boot**: Connects via systemd service (if enabled)
- **Silent**: Runs in background without interrupting workflow
- **Smart**: Only starts if not already running

### Management Commands
```bash
# Systemd service management
systemctl --user start input-leap.service    # Start service
systemctl --user stop input-leap.service     # Stop service  
systemctl --user enable input-leap.service   # Enable auto-start
systemctl --user status input-leap.service   # Check status
```

## ⚙️ Configuration

### Server Setup
During setup, you'll be prompted to enter your Input Leap server details:
- **IP with port**: `192.168.1.100:24800`
- **Hostname with port**: `desktop-pc:24800`  
- **IP only**: `192.168.1.100` (automatically adds default port 24800)

Configuration is saved to `~/.config/input-leap/server.conf`

### Client Name
The script automatically uses your hostname as the client name, but you can customize it during configuration.

## 📁 Project Structure

```
input-leap/
├── setup.sh                    # Main setup script for Arch Linux
├── setup-ubuntu.sh             # Placeholder for Ubuntu support
├── bin/                        # Executable scripts
│   ├── input-leap-manager      # Core management script
│   ├── leap                    # Simple command wrapper
│   ├── connect_input_leap.sh   # Legacy script (backup)
│   ├── install_input_leap.sh   # Legacy script (backup)
│   └── auto_input_leap.sh      # Legacy script (backup)
├── config/                     # Configuration templates
│   └── bashrc_integration.sh   # Shell integration
├── systemd/                    # Service definitions
│   └── input-leap.service      # Systemd service template
├── docs/                       # Documentation
│   └── GNOME-LAPTOP-SUPPORT.md # GNOME-specific guide
├── README.md                   # This file
└── .gitignore                  # Git ignore rules
```

### File Locations
- **Configuration**: `~/.config/input-leap/server.conf`
- **Logs**: `~/.cache/input-leap/client.log`
- **PID file**: `~/.cache/input-leap/client.pid`
- **Service file**: `~/.config/systemd/user/input-leap.service`

### Custom Configuration
You can manually edit the configuration file:
```bash
# Edit server configuration
nano ~/.config/input-leap/server.conf

# Test the configuration
leap test
```

## 🔧 Installation Details

The `setup.sh` script handles everything automatically:

### **System Detection:**
- **Desktop Environment**: GNOME, KDE, XFCE detection
- **System Type**: Laptop vs desktop identification  
- **Distribution**: Arch Linux validation
- **Existing Installations**: Smart detection and user choice

### **Package Installation** (Arch Linux):
- Tries official Arch repository first (`input-leap`)
- Falls back to AUR (`input-leap-git`) if needed
- Installs `yay` AUR helper automatically if required
- Validates installation before proceeding

### **GNOME + Xorg Optimizations:**
- 🔍 **Automatic GNOME detection** - Detects GNOME desktop environment
- 🔋 **Battery/power supply detection** - Smart laptop optimization
- 🔒 **Optional auto-lock disabling** - For seamless remote control
- ⚡ **X11 backend forcing** - Ensures perfect Xorg compatibility
- 🖥️ **Display environment configuration** - Proper DISPLAY and XDG variables
- 🔧 **GNOME shell extensions integration** - Native desktop integration
- 📱 **Desktop notifications setup** - Visual feedback system
- 🎯 **Wayland fallback handling** - Automatic X11 preference for stability

### **System Integration:**
- Creates systemd user service with proper dependencies
- Adds `leap` command to system PATH (with fallback to ~/.local/bin)
- Sets up auto-start in `.bashrc` with proper quoting
- Configures environment variables for GUI applications

### **Configuration & Testing:**
- Interactive server setup with input validation
- Network connectivity testing before connection
- Complete system testing and health checks
- Graceful error handling and recovery

## 🛠️ Troubleshooting

### Quick Diagnostics
```bash
# Check overall status
leap status

# Test server connection
leap test

# View recent logs
leap logs

# Restart connection
leap restart

# Reconfigure server
leap config
```

### Common Issues

#### Connection Failed
```bash
# Check if server is reachable
leap test

# Verify configuration
cat ~/.config/input-leap/server.conf

# Check firewall settings
sudo ufw status
```

#### Service Issues
```bash
# Check systemd service status
systemctl --user status input-leap.service

# View service logs
journalctl --user -u input-leap.service -f

# Restart service
systemctl --user restart input-leap.service
```

#### Manual Recovery
```bash
# Stop everything
leap stop
systemctl --user stop input-leap.service

# Clean up
rm -f ~/.cache/input-leap/client.pid
rm -f ~/.cache/input-leap/client.lock

# Restart
leap start
```

### GNOME-Specific Issues

#### Wayland vs Xorg Optimization
```bash
# Check current session type
echo $XDG_SESSION_TYPE

# View automatic Xorg optimization (built-in)
leap status  # Shows detected desktop environment

# Manual Xorg forcing (if needed)
export GDK_BACKEND=x11
leap restart
```

#### Complete GNOME Services Integration
```bash
# View GNOME-specific optimizations applied
leap logs | grep -i gnome

# Check power management settings
gsettings get org.gnome.desktop.screensaver lock-enabled
gsettings get org.gnome.desktop.session idle-delay

# Verify Xorg backend configuration
echo $GDK_BACKEND
```

#### Screen Lock & Power Management
```bash
# Run full GNOME optimizations
./setup.sh
# Choose option 1 if Input Leap already installed
# Select 'y' for auto-lock disabling when prompted

# Manual power management (if needed)
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.session idle-delay 0
```

## 🎯 Future Plans

### Ubuntu Support (Coming Soon!)
We're working on Ubuntu/Debian support with these planned features:

- **APT package management** with PPA support
- **Ubuntu GNOME optimizations** - Same level of GNOME/Xorg integration
- **Snap package detection** and handling
- **WSL compatibility** for Windows users
- **Unity desktop support** - Complete desktop environment coverage
- **Xorg service management** - Consistent X11 optimization across distributions

### Fedora & Other Distributions
- **DNF/YUM package management**
- **SELinux compatibility**
- **Flatpak integration**

**Want to help?** Contributions for other distributions are very welcome!

## 🚀 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup
```bash
# Clone the repository
git clone git@github.com:jorgemunozl/input-leap-computer.git
cd input-leap-computer

# Make scripts executable
chmod +x setup.sh bin/*

# Test the setup
./setup.sh
```

## � License

This project is open source and available under the MIT License.

## � Acknowledgments

- [Input Leap](https://github.com/input-leap/input-leap) - The amazing KVM software
- Arch Linux community for excellent packaging
- All contributors who help make this better

---

**Made with ❤️ for seamless computing**
