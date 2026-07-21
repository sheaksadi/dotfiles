#!/bin/bash

# --- MODE 1: THE DISCONNECT ACTION (Runs inside terminal) ---
if [ "$1" == "--disconnect" ]; then
    VPN_INTERFACE="$2"
    echo "--------------------------------"
    echo "Disabling VPN: $VPN_INTERFACE"
    echo "--------------------------------"
    sudo wg-quick down "$VPN_INTERFACE"
    echo "✅ VPN Disconnected."
    sleep 2
    exit 0
fi

# --- MODE 2: THE CONNECT ACTION (Runs inside terminal) ---
if [ "$1" == "--connect" ]; then
    echo "Scanning for VPN configs..."
    
    # Get config files
    # We list files, strip path, strip extension
    configs=$(sudo find /etc/wireguard -maxdepth 1 -name "*.conf" -printf "%f\n" | sed 's/\.conf$//')

    if [ -z "$configs" ]; then
        echo "❌ No .conf files found in /etc/wireguard/"
        read -p "Press Enter to exit..."
        exit 1
    fi

    # Use FZF for arrow key selection (or fall back to simple select if fzf is missing)
    if command -v fzf &> /dev/null; then
        SELECTED_VPN=$(echo "$configs" | fzf --height=20% --layout=reverse --border --prompt="Select VPN > ")
    else
        # Fallback if you don't have fzf installed
        echo "('fzf' not found, using number selection. Install fzf for arrow keys)"
        select vpn in $configs; do
            SELECTED_VPN=$vpn
            break
        done
    fi

    if [ -n "$SELECTED_VPN" ]; then
        echo "Connecting to $SELECTED_VPN..."
        sudo wg-quick up "$SELECTED_VPN"
        echo "✅ Connected!"
        sleep 2
    else
        echo "No VPN selected."
    fi
    exit 0
fi


# --- MODE 3: THE MAIN LOGIC (Runs from Waybar) ---

# Detect active WireGuard interface
ACTIVE_VPN=$(ip -o link show type wireguard | awk -F': ' '{print $2}')
SCRIPT_PATH=$(realpath "$0")

if [ -n "$ACTIVE_VPN" ]; then
    # VPN IS ON -> Launch script in 'disconnect' mode
    # We pass the active vpn name safely as an argument
    alacritty --class floating-term -e "$SCRIPT_PATH" --disconnect "$ACTIVE_VPN"
else
    # VPN IS OFF -> Launch script in 'connect' mode
    alacritty --class floating-term -e "$SCRIPT_PATH" --connect
fi
