#!/bin/bash

# Script to create virtual network interfaces for ONVIF server
# Requires root privileges

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Network interface to use (change if needed)
INTERFACE="enp8s0"

# Check if interface exists
if ! ip link show "$INTERFACE" &> /dev/null; then
    echo "Error: Network interface $INTERFACE not found!"
    echo "Available interfaces:"
    ip link show | grep -E '^[0-9]+:' | awk '{print $2}' | sed 's/://g'
    echo ""
    echo "Please edit this script and change the INTERFACE variable to match your network interface."
    exit 1
fi

echo "Creating virtual network interfaces on $INTERFACE..."
echo ""

# Create 32 virtual network interfaces
for i in {1..32}; do
    MAC_HEX=$(printf "%02x" $i)
    MAC_ADDRESS="a2:a2:a2:a2:00:$MAC_HEX"
    VLAN_NAME="onvif-proxy-$i"
    
    # Check if interface already exists
    if ip link show "$VLAN_NAME" &> /dev/null; then
        echo "Interface $VLAN_NAME already exists, skipping..."
    else
        # Create the virtual interface
        ip link add "$VLAN_NAME" link "$INTERFACE" address "$MAC_ADDRESS" type macvlan mode bridge
        
        # Bring the interface up
        ip link set "$VLAN_NAME" up
        
        echo "Created $VLAN_NAME with MAC address $MAC_ADDRESS"
    fi
done

echo ""
echo "Virtual network interfaces created successfully!"
echo ""
echo "To make these persistent across reboots, you'll need to add them to your network configuration."
echo ""
echo "To prevent cameras from showing the same stream, run:"
echo "sudo sysctl -w net.ipv4.conf.all.arp_ignore=1"
echo "sudo sysctl -w net.ipv4.conf.all.arp_announce=2"