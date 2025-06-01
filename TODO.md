# TODO: Implement Master Discovery Service Architecture

## Current Issue
When running multiple virtual ONVIF cameras (32 in our case), each camera instance tries to bind to the same UDP discovery port (3702), causing an "EADDRINUSE" error and crashing the application.

## Proposed Solution: Master Discovery Service Architecture

### Overview
Implement a single master discovery service that handles WS-Discovery for all virtual cameras, similar to how real multi-channel NVRs operate.

### Architecture Changes

1. **Separate Discovery from Camera Services**
   - Extract the discovery functionality from individual camera instances
   - Create a standalone discovery service that runs once
   - Keep individual ONVIF services running on their respective ports (8081-8112)

2. **Master Discovery Service**
   - Binds to UDP port 3702 (standard WS-Discovery port)
   - Maintains a registry of all active virtual cameras
   - Responds to discovery probes with information about all cameras
   - Each response includes:
     - Camera name
     - Unique UUID
     - IP address and port
     - Device capabilities

3. **Camera Registration**
   - When each virtual camera starts, it registers with the master discovery service
   - Registration includes: IP, port, UUID, name, and capabilities
   - Cameras can deregister when shutting down

### Implementation Steps

1. **Create discovery-service.js**
   - Standalone discovery service module
   - Manages camera registry
   - Handles WS-Discovery protocol

2. **Modify onvif-server.js**
   - Remove discovery initialization from individual cameras
   - Add registration with master discovery service
   - Keep all other ONVIF functionality intact

3. **Update main.js**
   - Start the master discovery service once before starting cameras
   - Pass discovery service reference to camera instances

### Benefits
- Eliminates port binding conflicts
- All cameras remain discoverable
- More efficient (1 discovery service vs 32)
- Better represents multi-channel NVR behavior
- Scalable to any number of cameras

### Testing
- Verify all 32 cameras are discovered by Unifi Protect
- Ensure each camera can be individually adopted
- Test that video streams work correctly
- Verify discovery works after service restart