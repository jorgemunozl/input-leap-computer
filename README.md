# 🖱️ Input Leap Auto-Setup

**Turn on your client and Input Leap is ready!**

Complete automation for Input Leap **CLIENT** setup and management. One command sets up everything you need for seamless mouse and keyboard sharing.

## 🎯 **What This Project Does**

**This is a CLIENT setup script** - it prepares the machine that will **receive** mouse/keyboard control from another computer.

### **📱 You Need TWO Machines:**
1. **🖥️ SERVER** = Your main computer (has the physical mouse/keyboard)
2. **💻 CLIENT** = Secondary computer (controlled remotely) ← **This script sets up the CLIENT**

### **🔄 How Input Leap Works:**
```
┌─────────────────┐    Network    ┌─────────────────┐
│   SERVER        │◄──────────────┤   CLIENT        │
│                 │               │                 │
│ 🖱️ Mouse        │               │ (Controlled)    │
│ ⌨️ Keyboard     │               │                 │
│ 🖥️ Main Screen  │               │ 📺 Extra Screen │
└─────────────────┘               └─────────────────┘
     (Controls)                       (Receives)
```

**Move your mouse to the edge** → Control switches to the client machine!  
**Move back** → Control returns to your server machine!

## 📋 **Complete Setup Workflow**

### **Step 1: Set Up This Machine (Client)**
```bash
cd input-leap
./install                    # Run our setup script
leap network static          # Configure static IP (recommended)
```

### **Step 2: Set Up Your Main Computer (Server)**
```bash
# On your main computer:
sudo pacman -S input-leap    # Install Input Leap server
input-leap-server --config  # Configure in GUI
# Add client IP: 169.254.135.230 (if using static IP)
# Set screen position (left/right/top/bottom)
# Start the server
```

### **Step 3: Connect!**
```bash
# On this machine (client):
leap start                   # Connect to server
leap status                  # Check connection
```

### **Step 4: Use It!**
- Move mouse to screen edge → control switches to client
- Move back → control returns to server
- Keyboard follows mouse automatically! 🎉

## 🤗 For Complete Beginners

**Never used a terminal? No problem!** Here's what you need to know:

### Step 1: Open Terminal
- **On most systems**: Press `Ctrl + Alt + T`
- **On GNOME**: Press `Super` key (Windows key) and type "terminal"
- **Still can't find it?** Look for "Terminal" or "Console" in your applications menu

### Step 2: Navigate to this project
When the black window opens, type this **exactly** (copy-paste works too):
```bash
cd input-leap
```
Press **Enter**. If you get an error like "No such file", you need to download this project first!

### Step 3: Run the magic command
**For Arch users:**
```bash
./install
```
**For Ubuntu/Debian users:**
```bash
./setup-ubuntu.sh
```
Press **Enter** and follow the colorful prompts!

### Step 4: Don't panic!
- If you see lots of text scrolling - **that's normal!** ✅
- If it asks for your password - **type it** (you won't see it, that's normal) ✅
- If it asks for server IP - **just press Enter** (you can set it later) ✅
- If something looks broken - **read the error message** (our scripts are helpful!) ✅

## 🚀 Quick Setup

> **👶 Never used Linux terminal before?** No worries! Just copy-paste the commands below and press Enter. That's it!

### **Arch Linux (Primary Focus)** ⚡
**Step 1:** Open a terminal (Ctrl+Alt+T) and navigate to this folder:
```bash
cd input-leap
```

**Step 2:** Run ONE of these commands:
```bash
# ✨ Super simple way (recommended)
./install

# 🔧 Traditional way (if you want to see more details)
./setup.sh
```
**Zero configuration needed!** Just press Enter when asked for your server IP - you can set it up later!

### **Ubuntu/Debian (Also Supported)**  
**Step 1:** Open terminal (Ctrl+Alt+T) and go to the folder:
```bash
cd input-leap
```
**Step 2:** Run the setup:
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

## 🖥️ **Server Setup (Your Main Computer)**

**⚠️ IMPORTANT:** This script only sets up the CLIENT. You also need to configure the SERVER machine!

### **On Your Main Computer (Server):**
1. **Install Input Leap Server**:
   - **Arch Linux**: `sudo pacman -S input-leap` 
   - **Ubuntu**: `sudo apt install input-leap`
   - **Other systems**: Download from [Input Leap releases](https://github.com/input-leap/input-leap/releases)

2. **Configure Server**:
   ```bash
   # Start the server GUI
   input-leap-server --config
   
   # Or run from applications menu: "Input Leap Server"
   ```

3. **Add This Client**:
   - In the server GUI, add your client machine
   - Use the client's hostname or IP address
   - Set up screen arrangement (left/right/top/bottom)

4. **Start Server**:
   ```bash
   input-leap-server --config /path/to/config.conf
   ```

### **🔧 Quick Server Setup:**
```bash
# On your main computer (server):
sudo pacman -S input-leap                    # Install server
input-leap-server --config                   # Configure clients
# Add your client machine's IP in the GUI
# Start the server
```

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
leap network static     # 🔧 Auto-configure Ethernet with static IP (RECOMMENDED!)
leap network auto       # 🔄 Auto-configure with DHCP
leap network test HOST  # 🔍 Test server connectivity
leap network check      # ✅ Check configured Input Leap server

# Static IP commands (for reliable connections)
leap network static                          # Auto-setup 169.254.135.230/16
leap network static enxc8a362 169.254.135.230  # Custom interface & IP
leap network static eth0 192.168.1.100 24   # Custom IP with netmask

# Short version (same commands)
leap net status         # Same as leap network status
leap net static         # Same as leap network static
```

**🎯 Static IP Features (NEW!):**
- **🔒 Fixed IP addresses** - No more DHCP changes breaking connections
- **🚀 Link-local networking** - Works without router/DHCP (169.254.x.x range)
- **⚡ Auto-detection** - Finds your Ethernet interface automatically
- **💾 Persistent config** - Remembers your settings across reboots
- **🔧 Manual override** - Set custom IPs for any interface
- **📋 Backup safety** - Saves old config before changes

**Smart Network Features:**
- **🔍 Auto-detects Ethernet** - Prioritizes wired over WiFi
- **⚡ DHCP magic** - Gets IP addresses automatically  
- **🔍 Connection testing** - Shows exactly what's wrong
- **🔄 Fallback handling** - Switches to WiFi if Ethernet fails
- **💡 Helpful error messages** - Tells you exactly how to fix issues

## 🛠️ Troubleshooting

### **🖱️ Client Commands (This Machine)**
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

### **🖥️ Server Commands (Your Main Computer)**
```bash
# Check if server is running
ps aux | grep input-leap-server

# Start server manually
input-leap-server --config /path/to/config.conf

# View server logs
journalctl -u input-leap-server

# Configure server GUI
input-leap-server --config
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
