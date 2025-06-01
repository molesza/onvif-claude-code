# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Virtual ONVIF Server that creates virtual ONVIF-compatible devices from RTSP streams. It's primarily designed to work around limitations in third-party camera support (e.g., Unifi Protect) by splitting multi-channel ONVIF devices into individual virtual devices.

## Key Architecture

### Core Components

1. **main.js** - Entry point that handles:
   - Command-line argument parsing
   - Configuration loading (YAML format)
   - Starting virtual ONVIF servers
   - Setting up TCP proxies for RTSP/snapshot streams

2. **src/onvif-server.js** - Main ONVIF server implementation:
   - Creates SOAP services for ONVIF Device and Media services
   - Handles device discovery via WS-Discovery
   - Manages video profiles and configurations
   - Implements ONVIF Profile S (streaming) functionality

3. **src/config-builder.js** - Auto-generates configuration:
   - Connects to real ONVIF devices
   - Extracts stream profiles and settings
   - Creates YAML configuration templates

### Dependencies
- **soap**: SOAP server/client implementation
- **node-tcp-proxy**: Proxies RTSP and snapshot streams
- **xml2js**: XML parsing for ONVIF messages
- **yaml**: Configuration file parsing
- **simple-node-logger**: Logging functionality

## Common Commands

### Running the Server
```bash
# Install dependencies
npm install

# Create configuration from existing ONVIF device
node main.js --create-config

# Run server with configuration
node main.js ./config.yaml

# Run with debug output
node main.js --debug ./config.yaml
```

### Docker Usage
```bash
# Run with mounted config
docker run --rm -it -v /path/to/config.yaml:/onvif.yaml ghcr.io/daniela-hase/onvif-server:latest

# Create config inside container
docker run --rm -it --entrypoint /bin/sh ghcr.io/daniela-hase/onvif-server:latest
```

## Configuration Structure

The server uses YAML configuration with this structure:
- **mac**: MAC address for virtual network interface
- **ports**: Server (ONVIF), RTSP, and snapshot ports
- **name**: Device name
- **uuid**: Unique device identifier
- **highQuality/lowQuality**: Stream configurations
  - rtsp: Path to RTSP stream
  - snapshot: Path to snapshot endpoint
  - width/height: Resolution
  - framerate: FPS
  - bitrate: kb/s
  - quality: 1-5 scale
- **target**: Real device connection info

## Network Requirements

Each virtual device requires a unique MAC address, typically created using MacVLAN:
```bash
sudo ip link add [NAME] link [INTERFACE] address [MAC] type macvlan mode bridge
```

## WSDL Files

The `wsdl/` directory contains ONVIF service definitions:
- **device_service.wsdl**: Device management service
- **media_service.wsdl**: Media streaming service

These define the SOAP interface for ONVIF compatibility.