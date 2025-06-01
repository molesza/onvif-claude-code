#!/bin/bash

# Script to request DHCP addresses for virtual interfaces
# Requires root privileges

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

echo "Requesting DHCP addresses for virtual interfaces..."
echo "This may take a minute..."

# Request DHCP for each interface
for i in {1..32}; do
    echo -n "Requesting IP for onvif-proxy-$i... "
    dhclient onvif-proxy-$i 2>/dev/null &
done

# Wait for all background processes
wait

echo ""
echo "DHCP requests sent. Checking IP addresses..."
echo ""

# Show assigned IPs
for i in {1..32}; do
    IP=$(ip addr show onvif-proxy-$i 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d'/' -f1)
    if [ -n "$IP" ]; then
        echo "onvif-proxy-$i: $IP"
    else
        echo "onvif-proxy-$i: No IP assigned yet"
    fi
done

echo ""
echo "Note: If some interfaces don't have IPs, they may need to be configured in your DHCP server"
echo "or you can assign static IPs manually."