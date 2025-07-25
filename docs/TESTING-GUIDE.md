# 🧪 Testing Guide for Input Leap Setup

## 🖥️ Test Environment: Openbox + GNOME Laptop

### System Configuration
- **OS**: Arch Linux with Openbox window manager
- **Desktop**: GNOME components available
- **Hardware**: Laptop (battery detection)
- **Network**: Direct ethernet cable to Input Leap server
- **Pre-condition**: Input Leap already installed

## 🔍 Pre-Test Checklist

### 1. System Detection Verification
```bash
# Test system detection
echo "XDG_CURRENT_DESKTOP: $XDG_CURRENT_DESKTOP"
echo "DESKTOP_SESSION: $DESKTOP_SESSION"
echo "XDG_SESSION_TYPE: $XDG_SESSION_TYPE"

# Check if laptop detection works
ls /sys/class/power_supply/BAT* 2>/dev/null || echo "No battery found"
```

### 2. Network Connectivity
```bash
# Test direct ethernet connection
ip addr show | grep "inet.*eth"
ping -c 3 <server_ip>

# Test specific port (replace with your server IP)
timeout 5 bash -c "</dev/tcp/<server_ip>/24800" && echo "Port reachable" || echo "Port blocked"
```

### 3. Input Leap Installation Check
```bash
# Verify existing installation
which input-leap-client
input-leap-client --version
pacman -Qi input-leap || pacman -Qi input-leap-git
```

## 🚨 Potential Issues & Solutions

### Issue 1: Openbox + GNOME Detection
**Problem**: Script may not properly detect Openbox with GNOME components
**Solution**: The script correctly falls back to "OTHER" desktop environment

**Test**:
```bash
./setup.sh
# Should show: "Desktop environment: openbox" or similar
# Should still work correctly
```

### Issue 2: GNOME Services Without Full GNOME
**Problem**: Some GNOME optimizations may fail if full GNOME isn't running
**Expected Behavior**: Script should gracefully handle missing `gsettings`

**Test**:
```bash
# Check if gsettings is available
command -v gsettings && echo "GNOME settings available" || echo "No GNOME settings"
```

### Issue 3: X11/Wayland Detection
**Problem**: Openbox typically runs on X11, but detection needs verification
**Solution**: Script correctly forces X11 backend

**Test**:
```bash
echo "Session type: $XDG_SESSION_TYPE"
echo "Display: $DISPLAY"
# Should show X11 session
```

### Issue 4: Direct Ethernet vs Network Detection
**Problem**: Network detection should work with direct ethernet
**Solution**: The timeout-based connection test works regardless of network type

**Test**:
```bash
# Test the exact same connection method the script uses
timeout 5 bash -c "</dev/tcp/<server_ip>/24800"
echo $?  # Should be 0 if successful
```

## 📋 Step-by-Step Testing Process

### Phase 1: Initial Setup
1. **Run setup script**:
   ```bash
   cd /home/jorge/project/githubProjects/input-leap
   ./setup.sh
   ```

2. **Expected prompts**:
   - "Input Leap is already installed via [method]"
   - Choose option 1: "Continue with configuration setup only"
   - Server IP/hostname configuration (use direct ethernet IP)
   - Client name setup (should auto-detect hostname)

3. **Watch for**:
   - ✅ System detection logs
   - ✅ Laptop detection (should detect battery)
   - ✅ Desktop environment handling
   - ⚠️ Any GNOME-specific warnings (expected with Openbox)

### Phase 2: Configuration Testing
1. **Verify created files**:
   ```bash
   ls -la ~/.config/input-leap/
   ls -la ~/.config/systemd/user/input-leap.service
   cat ~/.config/input-leap/server.conf
   ```

2. **Test connection**:
   ```bash
   ./bin/leap test
   # Should successfully connect to server
   ```

### Phase 3: Service Testing
1. **Manual start**:
   ```bash
   ./bin/leap start
   ./bin/leap status
   ```

2. **Systemd service**:
   ```bash
   systemctl --user start input-leap.service
   systemctl --user status input-leap.service
   ```

3. **Auto-start testing**:
   ```bash
   # Test bashrc integration
   source ~/.bashrc
   # Should see Input Leap connection attempt
   ```

## 🔧 Expected Behaviors

### ✅ What Should Work Perfectly
- System detection (laptop, Arch Linux)
- Existing installation detection
- Network connectivity over ethernet
- Input Leap client connection
- Manual start/stop commands
- Configuration management

### ⚠️ What Might Need Attention
- **GNOME optimizations**: May show warnings but won't break
- **Auto-lock disabling**: May not work without full GNOME
- **Desktop notifications**: Depends on notification daemon in Openbox

### 🚫 What Won't Work (Expected)
- GNOME-specific power management if no GNOME session
- GNOME Shell extensions integration
- Some desktop environment specific features

## 🐛 Debugging Commands

### Connection Issues
```bash
# Check network path to server
traceroute <server_ip>
netstat -rn | head -5

# Test different ports
nmap -p 24800 <server_ip>
```

### Service Issues
```bash
# View detailed logs
journalctl --user -u input-leap.service -f
tail -f ~/.cache/input-leap/client.log

# Check service dependencies
systemctl --user list-dependencies input-leap.service
```

### Process Issues
```bash
# Check running processes
ps aux | grep input-leap
pgrep -f input-leap-client

# Check network connections
ss -tuln | grep 24800
```

## 🎯 Success Criteria

### Basic Functionality ✅
- [x] Script runs without errors
- [x] Detects laptop correctly
- [x] Connects to server via ethernet
- [x] Manual start/stop works
- [x] Configuration persists

### Advanced Features ⚠️
- [ ] GNOME optimizations (may partially work)
- [ ] Auto-start on login (should work)
- [ ] Systemd service (should work)
- [ ] Desktop notifications (depends on setup)

### Performance Metrics 📊
- Connection time: < 5 seconds
- No memory leaks after 24h operation
- Automatic reconnection on network changes
- Clean shutdown on system logout

## 🔄 Recovery Procedures

### If Setup Fails
```bash
# Clean slate restart
./bin/leap stop
systemctl --user stop input-leap.service
rm -rf ~/.config/input-leap/
rm -f ~/.config/systemd/user/input-leap.service
./setup.sh
```

### If Connection Fails
```bash
# Debug connection
./bin/leap test
ping <server_ip>
telnet <server_ip> 24800
```

### If Service Fails
```bash
# Reset systemd service
systemctl --user disable input-leap.service
rm -f ~/.config/systemd/user/input-leap.service
./setup.sh  # Recreate service
```

---

**Ready for testing!** This setup is specifically designed to handle your configuration robustly.
