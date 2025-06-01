/**
 * Camera Registry - Manages registration of virtual ONVIF cameras
 * This module maintains a registry of all active cameras that need to be advertised
 * through the discovery service.
 */

class CameraRegistry {
    constructor() {
        this.cameras = new Map();
    }

    /**
     * Register a camera with the registry
     * @param {string} uuid - Unique identifier for the camera
     * @param {Object} cameraInfo - Camera information including:
     *   - name: Camera name
     *   - hostname: IP address or hostname
     *   - port: ONVIF service port
     *   - mac: MAC address
     *   - deviceServicePath: Path to device service (usually /onvif/device_service)
     */
    register(uuid, cameraInfo) {
        this.cameras.set(uuid, {
            ...cameraInfo,
            registeredAt: new Date()
        });
    }

    /**
     * Unregister a camera from the registry
     * @param {string} uuid - Unique identifier for the camera
     */
    unregister(uuid) {
        return this.cameras.delete(uuid);
    }

    /**
     * Get information for a specific camera
     * @param {string} uuid - Unique identifier for the camera
     * @returns {Object|undefined} Camera information or undefined if not found
     */
    getCamera(uuid) {
        return this.cameras.get(uuid);
    }

    /**
     * Get all registered cameras
     * @returns {Array} Array of camera objects with their UUIDs
     */
    getAllCameras() {
        return Array.from(this.cameras.entries()).map(([uuid, camera]) => ({
            uuid,
            ...camera
        }));
    }

    /**
     * Get the count of registered cameras
     * @returns {number} Number of registered cameras
     */
    getCount() {
        return this.cameras.size;
    }

    /**
     * Clear all registered cameras
     */
    clear() {
        this.cameras.clear();
    }
}

module.exports = CameraRegistry;