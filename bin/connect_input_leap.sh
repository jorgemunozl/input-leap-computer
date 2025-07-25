#!/bin/bash

# connect_input_leap.sh - Automatically connect to an Input Leap server on login
# Usage: scripts/connect_input_leap.sh [start|stop|restart|status|config]

# Configuration files
CONFIG="$HOME/.config/input-leap.conf"
LOG="$HOME/.cache/input-leap.log"
PIDFILE="$HOME/.cache/input-leap.pid"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ensure cache and config directories exist
mkdir -p "$(dirname "$CONFIG")"
mkdir -p "$(dirname "$LOG")"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

# Function to check if client is running
is_running() {
    if [ -f "$PIDFILE" ]; then
        local pid=$(cat "$PIDFILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            return 0
        else
            rm -f "$PIDFILE"
            return 1
        fi
    fi
    return 1
}

# Function to stop the client
stop_client() {
    if is_running; then
        local pid=$(cat "$PIDFILE")
        log_message "Stopping Input Leap client (PID: $pid)..."
        kill "$pid" 2>/dev/null
        
        # Wait for process to stop
        local count=0
        while ps -p "$pid" > /dev/null 2>&1 && [ $count -lt 10 ]; do
            sleep 1
            ((count++))
        done
        
        if ps -p "$pid" > /dev/null 2>&1; then
            log_message "Force killing Input Leap client..."
            kill -9 "$pid" 2>/dev/null
        fi
        
        rm -f "$PIDFILE"
        echo -e "${GREEN}✓ Input Leap client stopped${NC}"
    else
        echo -e "${YELLOW}⚠️  Input Leap client is not running${NC}"
    fi
}

# Function to configure server address
configure_server() {
    echo -e "${BLUE}🔧 Input Leap Configuration${NC}"
    echo "Current configuration:"
    if [ -f "$CONFIG" ]; then
        cat "$CONFIG"
        echo ""
        read -r -p "Update configuration? (y/N): " update
        if [[ ! $update =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi
    
    echo ""
    echo "Enter the Input Leap server details:"
    echo "Examples:"
    echo "  - 192.168.1.100:24800 (IP with default port)"
    echo "  - desktop-pc:24800 (hostname with port)"
    echo "  - 10.0.0.5 (IP only, will use default port 24800)"
    echo ""
    
    read -r -p "Server address (host:port or host): " SERVER
    
    # Add default port if not specified
    if [[ "$SERVER" != *":"* ]]; then
        SERVER="$SERVER:24800"
    fi
    
    echo "SERVER=\"$SERVER\"" > "$CONFIG"
    echo "CLIENT_NAME=\"$(hostname)\"" >> "$CONFIG"
    echo ""
    echo -e "${GREEN}✓ Configuration saved to $CONFIG${NC}"
}

# Function to start the client
start_client() {
    # Check if already running
    if is_running; then
        echo -e "${YELLOW}⚠️  Input Leap client is already running${NC}"
        return 0
    fi
    
    # Load configuration
    if [ ! -f "$CONFIG" ]; then
        echo -e "${YELLOW}⚠️  No configuration found. Setting up...${NC}"
        configure_server
    fi
    
    source "$CONFIG"
    
    # Validate server address
    if [ -z "$SERVER" ]; then
        echo -e "${RED}❌ No server address configured${NC}"
        return 1
    fi
    
    # Check for input-leap-client command
    if ! command -v input-leap-client &> /dev/null; then
        echo -e "${RED}❌ input-leap-client not found. Please install input-leap:${NC}"
        echo "   sudo pacman -S input-leap"
        echo "   # or from AUR:"
        echo "   yay -S input-leap-git"
        return 1
    fi
    
    # Test network connectivity to server
    local host=$(echo "$SERVER" | cut -d: -f1)
    local port=$(echo "$SERVER" | cut -d: -f2)
    
    if ! timeout 5 nc -z "$host" "$port" 2>/dev/null; then
        log_message "⚠️  Warning: Cannot connect to $SERVER (server may be offline)"
        echo -e "${YELLOW}⚠️  Server $SERVER is not reachable. Starting anyway...${NC}"
    fi
    
    # Start the client
    log_message "Starting Input Leap client, connecting to $SERVER..."
    echo -e "${BLUE}🔄 Starting Input Leap client...${NC}"
    
    # Prepare client name argument
    local client_args=()
    if [ -n "$CLIENT_NAME" ]; then
        client_args+=("--name" "$CLIENT_NAME")
    fi
    
    # Start client in background and capture PID
    nohup input-leap-client "${client_args[@]}" "$SERVER" >> "$LOG" 2>&1 &
    local pid=$!
    echo "$pid" > "$PIDFILE"
    
    # Give it a moment to start
    sleep 2
    
    # Check if it's still running
    if ps -p "$pid" > /dev/null 2>&1; then
        log_message "✓ Input Leap client started successfully (PID: $pid)"
        echo -e "${GREEN}✓ Input Leap client started (PID: $pid)${NC}"
        echo -e "${BLUE}📄 Logs: $LOG${NC}"
        return 0
    else
        rm -f "$PIDFILE"
        log_message "❌ Input Leap client failed to start"
        echo -e "${RED}❌ Failed to start Input Leap client${NC}"
        echo "Check logs: tail -f $LOG"
        return 1
    fi
}

# Function to show status
show_status() {
    echo -e "${BLUE}📊 Input Leap Client Status${NC}"
    echo "=========================="
    
    if is_running; then
        local pid=$(cat "$PIDFILE")
        echo -e "${GREEN}✓ Running (PID: $pid)${NC}"
        
        if [ -f "$CONFIG" ]; then
            source "$CONFIG"
            echo "Server: $SERVER"
            echo "Client Name: ${CLIENT_NAME:-$(hostname)}"
        fi
        
        echo "Log file: $LOG"
        echo ""
        echo "Recent log entries:"
        tail -5 "$LOG" 2>/dev/null || echo "No log entries found"
    else
        echo -e "${RED}❌ Not running${NC}"
    fi
}

# Main script logic
case "${1:-start}" in
    start)
        start_client
        ;;
    stop)
        stop_client
        ;;
    restart)
        stop_client
        sleep 1
        start_client
        ;;
    status)
        show_status
        ;;
    config)
        configure_server
        ;;
    *)
        echo "Usage: $0 [start|stop|restart|status|config]"
        echo ""
        echo "Commands:"
        echo "  start   - Start Input Leap client (default)"
        echo "  stop    - Stop Input Leap client"
        echo "  restart - Restart Input Leap client"
        echo "  status  - Show client status and logs"
        echo "  config  - Configure server address"
        echo ""
        echo "Configuration file: $CONFIG"
        echo "Log file: $LOG"
        exit 1
        ;;
esac
