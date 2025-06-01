/**
 * Master Discovery Service - Handles WS-Discovery for all virtual ONVIF cameras
 * This service runs once and responds to discovery probes with information about
 * all registered cameras, eliminating port conflicts.
 */

const dgram = require('dgram');
const xml2js = require('xml2js');
const uuid = require('node-uuid');
const CameraRegistry = require('./camera-registry');

class DiscoveryService {
    constructor(logger) {
        this.logger = logger;
        this.registry = new CameraRegistry();
        this.discoverySocket = null;
        this.messageCounter = 0;
        this.multicastAddress = '239.255.255.250';
        this.discoveryPort = 3702;
    }

    /**
     * Start the discovery service
     * @param {string} bindInterface - Network interface IP to bind to (optional)
     */
    start(bindInterface) {
        this.discoverySocket = dgram.createSocket({ type: 'udp4', reuseAddr: true });
        
        this.discoverySocket.on('message', (message, remote) => {
            this.handleDiscoveryMessage(message, remote);
        });

        this.discoverySocket.on('error', (error) => {
            this.logger.error(`Discovery service error: ${error.message}`);
        });

        this.discoverySocket.bind(this.discoveryPort, () => {
            this.logger.info(`Master discovery service started on port ${this.discoveryPort}`);
            
            // Join multicast group on all interfaces or specific interface
            if (bindInterface) {
                this.discoverySocket.addMembership(this.multicastAddress, bindInterface);
            } else {
                this.discoverySocket.addMembership(this.multicastAddress);
            }
        });
    }

    /**
     * Stop the discovery service
     */
    stop() {
        if (this.discoverySocket) {
            this.discoverySocket.close();
            this.discoverySocket = null;
            this.logger.info('Master discovery service stopped');
        }
    }

    /**
     * Handle incoming discovery messages
     */
    handleDiscoveryMessage(message, remote) {
        xml2js.parseString(message.toString(), { 
            tagNameProcessors: [xml2js.processors.stripPrefix] 
        }, (err, result) => {
            if (err) {
                this.logger.error(`Failed to parse discovery message: ${err.message}`);
                return;
            }

            try {
                const envelope = result['Envelope'];
                const header = envelope['Header'][0];
                const body = envelope['Body'][0];
                
                // Check if this is a Probe message
                if (!body['Probe']) {
                    return;
                }

                const probeUuid = header['MessageID'][0];
                let probeType = '';
                
                try {
                    probeType = body['Probe'][0]['Types'][0];
                    if (typeof probeType === 'object') {
                        probeType = probeType._;
                    }
                } catch (err) {
                    // No specific type requested, respond to all
                }

                // Check if we should respond to this probe
                if (probeType === '' || probeType.indexOf('NetworkVideoTransmitter') > -1) {
                    this.sendProbeMatches(probeUuid, remote);
                }
            } catch (err) {
                this.logger.error(`Error processing discovery message: ${err.message}`);
            }
        });
    }

    /**
     * Send ProbeMatches response for all registered cameras
     */
    sendProbeMatches(probeUuid, remote) {
        const cameras = this.registry.getAllCameras();
        
        if (cameras.length === 0) {
            this.logger.debug('No cameras registered, not sending discovery response');
            return;
        }

        // Build ProbeMatch elements for all cameras
        const probeMatches = cameras.map(camera => {
            return `
                    <d:ProbeMatch>
                        <wsa:EndpointReference>
                            <wsa:Address>urn:uuid:${camera.uuid}</wsa:Address>
                        </wsa:EndpointReference>
                        <d:Types>dn:NetworkVideoTransmitter</d:Types>
                        <d:Scopes>
                            onvif://www.onvif.org/type/video_encoder
                            onvif://www.onvif.org/type/ptz
                            onvif://www.onvif.org/hardware/Onvif
                            onvif://www.onvif.org/name/Cardinal
                            onvif://www.onvif.org/location/
                            onvif://www.onvif.org/Profile/Streaming
                        </d:Scopes>
                        <d:XAddrs>http://${camera.hostname}:${camera.port}/onvif/device_service</d:XAddrs>
                        <d:MetadataVersion>1</d:MetadataVersion>
                    </d:ProbeMatch>`;
        }).join('');

        const response = `<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://www.w3.org/2003/05/soap-envelope" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:d="http://schemas.xmlsoap.org/ws/2005/04/discovery" xmlns:dn="http://www.onvif.org/ver10/network/wsdl">
    <SOAP-ENV:Header>
        <wsa:MessageID>uuid:${uuid.v1()}</wsa:MessageID>
        <wsa:RelatesTo>${probeUuid}</wsa:RelatesTo>
        <wsa:To SOAP-ENV:mustUnderstand="true">http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To>
        <wsa:Action SOAP-ENV:mustUnderstand="true">http://schemas.xmlsoap.org/ws/2005/04/discovery/ProbeMatches</wsa:Action>
        <d:AppSequence SOAP-ENV:mustUnderstand="true" MessageNumber="${this.messageCounter++}" InstanceId="${Date.now()}"/>
    </SOAP-ENV:Header>
    <SOAP-ENV:Body>
        <d:ProbeMatches>${probeMatches}
        </d:ProbeMatches>
    </SOAP-ENV:Body>
</SOAP-ENV:Envelope>`;

        const responseBuffer = Buffer.from(response);
        const responseSocket = dgram.createSocket('udp4');
        
        responseSocket.send(responseBuffer, 0, responseBuffer.length, remote.port, remote.address, (err) => {
            if (err) {
                this.logger.error(`Failed to send discovery response: ${err.message}`);
            } else {
                this.logger.debug(`Sent discovery response with ${cameras.length} cameras to ${remote.address}:${remote.port}`);
            }
            responseSocket.close();
        });
    }

    /**
     * Get the camera registry
     * @returns {CameraRegistry} The camera registry instance
     */
    getRegistry() {
        return this.registry;
    }
}

module.exports = DiscoveryService;