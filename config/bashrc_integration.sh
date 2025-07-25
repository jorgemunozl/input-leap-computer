#!/bin/bash

# Input Leap Auto-Start Integration
# This file is sourced by .bashrc to provide seamless auto-start

# Only run in interactive shells
[[ $- != *i* ]] && return

# Find the project root (this file is in config/)
readonly CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$CONFIG_DIR")"
readonly LEAP_MANAGER="$PROJECT_ROOT/bin/input-leap-manager"

# Auto-start Input Leap (only if not already running and in a terminal session)
auto_start_input_leap() {
    # Only run if Input Leap is installed and manager exists
    if [[ -x "$LEAP_MANAGER" ]] && command -v input-leap-client &> /dev/null; then
        
        # Check if already running
        if ! "$LEAP_MANAGER" status &>/dev/null | grep -q "Running"; then
            
            # Start in background, suppress output
            {
                "$LEAP_MANAGER" start > /dev/null 2>&1
                
                # Optional notification (only if notify-send is available)
                if command -v notify-send &> /dev/null; then
                    notify-send "Input Leap" "Auto-connecting..." -t 2000 2>/dev/null || true
                fi
            } &
            
            # Don't wait for background process
            disown
        fi
    fi
}

# Create leap alias if not already exists
if ! type leap &> /dev/null; then
    alias leap="$LEAP_MANAGER"
fi

# Auto-start on shell startup (only once per session)
if [[ -z "${INPUT_LEAP_AUTOSTARTED:-}" ]]; then
    export INPUT_LEAP_AUTOSTARTED=1
    auto_start_input_leap
fi
