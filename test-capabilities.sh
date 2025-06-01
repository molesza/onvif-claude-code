#!/bin/bash

# Test GetCapabilities for a camera

CAMERA_IP="${1:-192.168.104.170}"
CAMERA_PORT="${2:-8081}"

echo "Testing GetCapabilities for $CAMERA_IP:$CAMERA_PORT"

cat > /tmp/get_capabilities.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" 
               xmlns:tds="http://www.onvif.org/ver10/device/wsdl">
  <soap:Body>
    <tds:GetCapabilities>
      <tds:Category>All</tds:Category>
    </tds:GetCapabilities>
  </soap:Body>
</soap:Envelope>
EOF

echo "Response:"
curl -s -X POST \
  -H "Content-Type: application/soap+xml; charset=utf-8" \
  -d @/tmp/get_capabilities.xml \
  http://$CAMERA_IP:$CAMERA_PORT/onvif/device_service | sed 's/></>\n</g' | head -20

rm -f /tmp/get_capabilities.xml