
#!/bin/bash
set -euo pipefail

# auto_input_leap.sh - Quick setup for Input Leap auto-connection
# Add this to your .bashrc or login scripts

# Path to the Input Leap connection script (project-relative)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LEAP_SCRIPT="$PROJECT_ROOT/bin/connect_input_leap.sh"

# Only run if the script exists and Input Leap is installed
if [ -x "$LEAP_SCRIPT" ] && command -v input-leap-client &> /dev/null; then
    # Check if Input Leap is already running
    if ! pgrep -f input-leap-client > /dev/null; then
        # Start Input Leap in the background, suppress output
        "$LEAP_SCRIPT" start > /dev/null 2>&1 &
        
        # Optional: Show a brief notification (requires notify-send)
        if command -v notify-send &> /dev/null; then
            notify-send "Input Leap" "Connecting to server..." -t 3000 2>/dev/null &
        fi
    fi
fi
