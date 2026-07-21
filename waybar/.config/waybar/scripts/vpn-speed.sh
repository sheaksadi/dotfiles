#!/bin/bash

# Find ProtonVPN interface
VPN_INTERFACE=$(ip link show | grep -o 'protonvpn-[^:]*' | head -n1)

if [ -z "$VPN_INTERFACE" ]; then
    echo '{"text":"No VPN","class":"disconnected"}'
    exit 0
fi

# Get current bytes
RX1=$(cat /sys/class/net/$VPN_INTERFACE/statistics/rx_bytes)
TX1=$(cat /sys/class/net/$VPN_INTERFACE/statistics/tx_bytes)

sleep 1

# Get bytes after 1 second
RX2=$(cat /sys/class/net/$VPN_INTERFACE/statistics/rx_bytes)
TX2=$(cat /sys/class/net/$VPN_INTERFACE/statistics/tx_bytes)

# Calculate speed in KB/s
RX_SPEED=$(( ($RX2 - $RX1) / 1024 ))
TX_SPEED=$(( ($TX2 - $TX1) / 1024 ))

# Format output
if [ $RX_SPEED -gt 1024 ]; then
    RX_TEXT="$(( $RX_SPEED / 1024 ))MB/s"
else
    RX_TEXT="${RX_SPEED}KB/s"
fi

if [ $TX_SPEED -gt 1024 ]; then
    TX_TEXT="$(( $TX_SPEED / 1024 ))MB/s"
else
    TX_TEXT="${TX_SPEED}KB/s"
fi

echo "{\"text\":\"$VPN_INTERFACE ↓$RX_TEXT ↑$TX_TEXT\",\"class\":\"connected\"}"
