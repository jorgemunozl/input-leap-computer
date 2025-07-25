# 🖱️ Input Leap Auto-Setup

**Turn on your client and Input Leap is ready!**

A complete, robust automation system for Input Leap client setup and management. One command sets up everything you need for seamless mouse and keyboard sharing between your devices.

## ✨ Features

- � **One-command setup** - Everything configured automatically
- 🔄 **Auto-connection** - Connects automatically on startup/login
- 🛡️ **Robust error handling** - Graceful failure recovery
- 📊 **Smart status monitoring** - Real-time connection health checks
- 🔧 **Easy management** - Simple commands for all operations
- 📱 **Desktop notifications** - Visual feedback for connection status
- 🎯 **Zero configuration** - Works out of the box after setup
- 🔒 **Safe installation** - Backup and rollback capabilities

## 🚀 Quick Start

**One command to rule them all:**

```bash
./setup.sh
```

That's it! The script will:
1. Install Input Leap (from official repos or AUR)
2. Configure your server connection
3. Set up auto-start on login
4. Test everything works
5. Create convenient `leap` command

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
├── setup.sh                    # Main setup script - run this first!
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

1. **Package Installation**:
   - Tries official Arch repository first
   - Falls back to AUR (`input-leap-git`) if needed
   - Installs `yay` AUR helper if required

2. **System Integration**:
   - Creates systemd user service
   - Adds `leap` command to system PATH
   - Sets up auto-start in `.bashrc`

3. **Configuration**:
   - Interactive server setup
   - Network connectivity validation
   - Complete system testing

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
