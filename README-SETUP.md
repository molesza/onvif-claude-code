# ONVIF Server Setup for 32-Channel NVR

This repository contains configuration and helper scripts for running a virtual ONVIF server that splits a 32-channel NVR into individual virtual cameras for Unifi Protect compatibility.

## NVR Configuration
- **NVR IP**: 192.168.6.201
- **Channels**: 32
- **Username**: admin
- **Password**: [Stored in config.yaml - not committed]

## Setup Scripts

### 1. setup-mac-addresses.sh
Assigns unique MAC addresses to the configuration file for each virtual camera.
- MAC pattern: a2:a2:a2:a2:00:01 through a2:a2:a2:a2:00:20

### 2. setup-virtual-networks.sh
Creates virtual network interfaces using MacVLAN for each camera.
- Interface: enp8s0
- Creates 32 virtual interfaces (onvif-proxy-1 through onvif-proxy-32)

### 3. request-dhcp.sh
Requests DHCP addresses for all virtual interfaces.

### 4. run-onvif-server.sh
Runs the ONVIF server with automatic restart on failure.

## Quick Start

1. Install dependencies:
   ```bash
   npm install
   ```

2. Generate configuration:
   ```bash
   node main.js --create-config
   # Enter: 192.168.6.201, admin, [password]
   ```

3. Assign MAC addresses:
   ```bash
   ./setup-mac-addresses.sh
   ```

4. Create virtual networks (requires root):
   ```bash
   sudo ./setup-virtual-networks.sh
   ```

5. Configure ARP settings:
   ```bash
   sudo sysctl -w net.ipv4.conf.all.arp_ignore=1
   sudo sysctl -w net.ipv4.conf.all.arp_announce=2
   ```

6. Request DHCP addresses:
   ```bash
   sudo ./request-dhcp.sh
   ```

7. Run the server:
   ```bash
   ./run-onvif-server.sh
   ```

## Current Status
The server successfully starts all 32 virtual cameras but crashes due to discovery service port conflicts. See TODO.md for planned improvements to implement a master discovery service architecture.