# 🖱️ Input Leap Auto-Setup

**Turn on your client and Input Leap is ready!**

Complete automation for Input Leap client setup and management. One command sets up everything you need for seamless mouse and keyboard sharing.

## 🚀 Quick Setup

### **Arch Linux (Primary Focus)** ⚡
```bash
# Super simple way
./install

# Or traditional way  
./setup.sh
```
**Zero configuration needed!** Automatically detects and optimizes everything.

### **Ubuntu/Debian (Also Supported)**  
```bash
./setup-ubuntu.sh
```

### **2. Enter Your Server Details**
When prompted, enter your Input Leap server information:

**Format options:**
- `192.168.1.100` (IP only - adds default port 24800)
- `192.168.1.100:24800` (IP with custom port)
- `my-desktop` (hostname only - adds default port 24800)
- `my-desktop:24800` (hostname with custom port)

**Examples:**
```
Enter Input Leap server IP/hostname: 192.168.1.100
Enter Input Leap server IP/hostname: desktop-pc:24800
```

### **3. Done!**
**For Arch Linux users**: The script automatically detects and optimizes everything:
- Detects your system (GNOME/KDE/XFCE, laptop/desktop)
- Installs Input Leap (official repos + AUR fallback)
- **Automatically applies GNOME optimizations** (no questions asked!)
- Sets up auto-start on login
- Configures network interfaces seamlessly
- Tests the connection

**For Ubuntu users**: Similar automation with Ubuntu-specific optimizations.

## 🏗️ **Why Arch Linux Gets the Best Experience**

This project is **optimized for Arch Linux** because:
- **AUR integration** - Falls back to `input-leap-git` automatically
- **GNOME detection** - Automatically optimizes screen lock, power management
- **Zero prompts** - No annoying questions, just works
- **Network magic** - Seamless Ethernet detection and configuration
- **systemd perfection** - Auto-configured user services

## 💻 Usage

### 🖱️ **Basic Commands**
```bash
leap start      # Connect to server
leap stop       # Disconnect  
leap status     # Check status with real-time info
leap config     # Configure server (with examples!)
leap test       # Test connection with helpful tips
```

### 🌐 **Network Management**
```bash
# Quick network fixes
leap network status     # 📊 Show all interfaces with IP/status  
leap network auto       # 🔧 Auto-configure best interface
leap network test HOST  # 🔍 Test server connectivity
leap network check      # ✅ Check configured Input Leap server

# Short version (same commands)
leap net status         # Same as leap network status
leap net auto           # Same as leap network auto
```

**Smart Network Features:**
- **🔍 Auto-detects Ethernet** - Prioritizes wired over WiFi
- **⚡ DHCP magic** - Gets IP addresses automatically  
- **🔍 Connection testing** - Shows exactly what's wrong
- **🔄 Fallback handling** - Switches to WiFi if Ethernet fails
- **💡 Helpful error messages** - Tells you exactly how to fix issues

## 🛠️ Troubleshooting

```bash
# Check status
leap status

# Test server connection  
leap test

# View logs
leap logs

# Restart everything
leap restart

# Change server settings
leap config
```

### 🌐 Network Issues

```bash
# Check network interfaces
leap network status

# Auto-fix network issues
leap network auto

# Test specific server
leap network test 192.168.1.100:24800

# Check configured server
leap network check
```

**Common Network Problems:**
- **No Ethernet connection** - Run `leap network auto` to configure
- **Wrong interface active** - Use `leap network status` to see all interfaces
- **Server unreachable** - Use `leap network test SERVER` to verify connectivity

## 📁 Files & Configuration

### Important Files
- **Configuration**: `~/.config/input-leap/server.conf`
- **Logs**: `~/.cache/input-leap/client.log`
- **Service**: `~/.config/systemd/user/input-leap.service`

### Project Structure
```
input-leap/
├── setup.sh                    # Arch Linux setup
├── setup-ubuntu.sh             # Ubuntu/Debian setup  
├── bin/
│   ├── input-leap-manager      # Core management
│   ├── leap                    # Simple commands
│   └── validate-environment    # System check
└── systemd/
    └── input-leap.service      # Service template
```

## 🚀 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/name`
3. Commit changes: `git commit -m 'Add feature'`
4. Push: `git push origin feature/name`
5. Open Pull Request

## 📄 License

MIT License - see LICENSE file for details.

---

**Made with ❤️ for seamless computing**
