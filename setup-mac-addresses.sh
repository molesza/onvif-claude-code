#!/bin/bash

# Script to assign unique MAC addresses to the config.yaml file
# Base MAC address pattern: a2:a2:a2:a2:XX:YY where XX:YY are unique per channel

CONFIG_FILE="config.yaml"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found!"
    exit 1
fi

# Create a backup
cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"

# Generate and replace MAC addresses
for i in {1..32}; do
    # Generate MAC address in format a2:a2:a2:a2:00:XX
    MAC_HEX=$(printf "%02x" $i)
    MAC_ADDRESS="a2:a2:a2:a2:00:$MAC_HEX"
    
    # Replace the first occurrence of the placeholder
    sed -i "0,/<ONVIF PROXY MAC ADDRESS HERE>/s/<ONVIF PROXY MAC ADDRESS HERE>/$MAC_ADDRESS/" "$CONFIG_FILE"
    
    echo "Channel $i: Assigned MAC address $MAC_ADDRESS"
done

echo ""
echo "MAC addresses have been assigned successfully!"
echo "Backup saved as ${CONFIG_FILE}.backup"
echo ""
echo "Next steps:"
echo "1. Create virtual network interfaces for each MAC address"
echo "2. Run the ONVIF server with: node main.js config.yaml"