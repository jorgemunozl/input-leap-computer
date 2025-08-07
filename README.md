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

---

## ⚡ **Quick Start**

### 🖥️ **Server (Main Computer) Setup**
```bash
# Install Input Leap server on your main computer
sudo pacman -S input-leap

# NEW: Minimalist setup commands
leap-server config      # One-time configuration
leap-server add-client  # Add client machine(s)  
leap-server start       # Start the server
```

### 💻 **Client (This Computer) Setup**
```bash
# Install & configure this client
curl -sSL https://raw.githubusercontent.com/your-username/input-leap/main/install | bash

# Connect to server
leap-client connect     # NEW: Simple connection
# OR use traditional command
leap start              # Traditional way
```

**🎯 That's it! Move mouse to edge to switch control.**

---

## 📋 **Complete Setup Workflow**

### **Step 1: Set Up This Machine (Client)**
```bash
cd input-leap
./install                    # Run our setup script (asks about network preference)
```

**🔧 During setup, you'll choose:**
- **Server - Leap Ethernet (169.254.135.230)** - Primary client, most reliable
- **Client - Leap Ethernet (169.254.135.231)** - Secondary client, for additional machines  
- **Dynamic LAN/WiFi** - Use existing network (may need reconfiguration)
- **Manual setup** - Configure network later with `leap network` commands

**💡 The script automatically validates sudo access for seamless installation!**

### **Step 2: Set Up Your Main Computer (Server)**
```bash
# On your main computer:
sudo pacman -S input-leap    # Install Input Leap server

# Minimalist setup (NEW!):
curl -O https://raw.githubusercontent.com/jorgemunozl/input-leap-computer/main/bin/leap-server
chmod +x leap-server
./leap-server config         # Configure server
./leap-server add-client     # Add this client machine
./leap-server start          # Start server
```

**🎯 NEW: Minimalist Commands!**
- **SERVER**: `leap-server start` (simple terminal command!)
- **CLIENT**: `leap-client connect` (or `leap start`)

**⚠️ Two Setup Options:**
1. **GUI Way**: `input-leap-server --config` → Click "Start" button
2. **Minimalist Way**: `leap-server config` → `leap-server start` ✨

### **Step 3: Connect!**
```bash
# On this machine (client):
leap-client connect          # NEW: Simple connect command!
# OR the traditional way:
leap start                   # Connect to server
leap status                  # Check connection
```

**🔄 Complete workflow (MINIMALIST):**
1. **SERVER**: `leap-server start` 
2. **CLIENT**: `leap-client connect`
3. **Result**: Mouse/keyboard sharing active! 🎉

**🔄 How it works:**
- **Server OFF** → Client cannot connect (will show "server unreachable")
- **Server ON** (GUI started) → Client connects automatically (if auto-start enabled)
- **Server STOPS** → Client disconnects automatically

**💡 Remember:**
- **SERVER**: `leap-server start` (NEW minimalist way!) or GUI
- **CLIENT**: `leap-client connect` (NEW!) or `leap start`

### **Step 4: Use It!**
- Move mouse to screen edge → control switches to client
- Move back → control returns to server
- Keyboard follows mouse automatically! 🎉

## � Why Isn't My Server Starting Automatically?

**Input Leap servers are NEVER automatic!** Here's why:

1. **Security**: Servers don't auto-start to prevent unauthorized access
2. **Control**: You decide when to share your mouse/keyboard
3. **Resources**: Only runs when you actually need it

**The workflow is:**
1. **Main computer**: `leap-server start` (NEW!) or GUI → Click "Start"
2. **This machine**: `leap-client connect` (NEW!) or `leap start`
3. **Use Input Leap**: Move mouse/keyboard seamlessly
4. **Done**: `leap-server stop` or stop server GUI when finished

**Common mistakes:**
- ❌ Expecting server to start automatically 
- ❌ Running `leap start` on server (use `leap-server start` instead!)
- ❌ Forgetting to start server before connecting client
- ❌ Not configuring client IP on server
- ✅ `leap-server start` first, then `leap-client connect`

## �🤗 For Complete Beginners

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

**🌐 Network Choice:** During setup, you'll choose your preferred network configuration:
- **Server - Leap Ethernet (169.254.135.230)** - Primary client, most reliable
- **Client - Leap Ethernet (169.254.135.231)** - Secondary client, for multiple machines
- **Dynamic LAN/WiFi** - Uses existing network  
- **Manual setup** - Configure later

**🔐 Seamless Installation:** Script automatically validates sudo access upfront!

**Zero extra configuration needed!** Just choose your network preference and press Enter when asked for your server IP - you can set it up later!

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
# NEW: Minimalist commands
leap-client connect  # Connect to server (simple!)
leap-client config   # Configure server IP
leap-client status   # Check connection

# Traditional commands (still work)
leap start      # Connect to server
leap stop       # Disconnect  
leap status     # Check status with real-time info
leap config     # Configure server (with examples!)
leap test       # Test connection with helpful tips
leap ethernet   # Quick Leap Ethernet setup (server/client role)
leap ethernet forever # Permanent ethernet setup (survives reboots)
```

### 🖥️ **Server Commands (NEW!)**
```bash
# NEW: Minimalist server management
leap-server config      # Configure server (one-time)
leap-server add-client  # Add client machine
leap-server start       # Start Input Leap server
leap-server stop        # Stop server
leap-server status      # Check server status
```

### 🌐 **Network Management**
```bash
# Quick network fixes
leap ethernet           # 🔧 Quick Leap Ethernet setup (server/client role selection)
leap ethernet forever   # 🔒 Permanent Leap Ethernet setup with systemd-networkd (survives reboots)
leap network status     # 📊 Show all interfaces with IP/status  
leap network static     # 🔧 Auto-configure Ethernet with static IP (RECOMMENDED!)
leap network auto       # 🔄 Auto-configure with DHCP
leap network test HOST  # 🔍 Test server connectivity
leap network check      # ✅ Check configured Input Leap server

# Static IP commands (for reliable connections)
leap network static                          # Auto-setup 169.254.135.230/16 (primary)
leap network static_ip 169.254.135.231      # Setup with secondary IP
leap network static enxc8a362 169.254.135.230  # Custom interface & IP
leap network static eth0 192.168.1.100 24   # Custom IP with netmask

# Short version (same commands)
leap net status         # Same as leap network status
leap net static         # Same as leap network static
```

**🎯 Leap Ethernet Features (NEW!):**
- **🔒 Fixed IP addresses** - No more DHCP changes breaking connections
- **🚀 Link-local networking** - Works without router/DHCP (169.254.x.x range)
- **⚡ Auto-detection** - Finds your Ethernet interface automatically
- **💾 Persistent config** - Remembers your settings across reboots
- **🔧 Manual override** - Set custom IPs for any interface
- **📋 Backup safety** - Saves old config before changes

**🔧 Ethernet Command Options:**
- **`leap ethernet`** - Quick temporary setup (NetworkManager-based, resets on reboot)
- **`leap ethernet forever`** - Permanent setup (systemd-networkd, survives reboots) ⚡ **RECOMMENDED**

**💡 When to use each:**
- **Temporary (`leap ethernet`)**: Testing, one-time use, or when you want to easily revert
- **Permanent (`leap ethernet forever`)**: Production use, daily workflow, permanent Input Leap setup

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

---

## 🎯 **Command Reference**

### 🖥️ **Server Commands (NEW!)**
```bash
leap-server config      # Configure server (one-time setup)
leap-server add-client  # Add client machine to server
leap-server start       # Start Input Leap server
leap-server stop        # Stop Input Leap server  
leap-server status      # Check server status
```

### 💻 **Client Commands**
```bash
# NEW Minimalist Commands
leap-client connect     # Connect to server (simple!)
leap-client config      # Configure server IP
leap-client status      # Check connection status

# Traditional Commands (still work)
leap start             # Connect to server
leap stop              # Disconnect from server
leap status            # Detailed connection status
leap config            # Configure server with examples
leap test              # Test connection with tips
leap network auto      # Auto-configure static IP
```

### 🌐 **Network Commands**
```bash
leap ethernet          # Quick Leap Ethernet setup (server/client role selection)
leap ethernet forever  # Permanent Leap Ethernet setup (systemd-networkd, survives reboots)
leap network status    # Check network interfaces
leap network auto      # Auto-configure static IP
leap network manual    # Manual IP configuration
leap network check     # Network diagnostics
leap network test IP   # Test connectivity to server
```

**🎉 Most Common Workflow:**
1. **Server**: `leap-server config` → `leap-server add-client` → `leap-server start`
2. **Client**: `leap-client connect`
3. **Done!** Move mouse to edge to switch control

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

## 🛣️ Make leap/leap-server Available Everywhere

To use `leap`, `leap-server`, and all related commands from any directory, add the `bin` folder to your PATH:

```bash
# Add this to your ~/.bashrc (or ~/.zshrc)
export PATH="$HOME/project/githubProjects/input-leap/bin:$PATH"
```

Then reload your shell:
```bash
source ~/.bashrc
```

Now you can run `leap`, `leap-server`, etc. from anywhere!

---

**Made with ❤️ for seamless computing**
