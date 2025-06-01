#!/bin/bash

# Test script for manually verifying ONVIF camera endpoints

CAMERA_IP="192.168.104.170"  # Channel 1
CAMERA_PORT="8081"
USERNAME="admin"
PASSWORD="Nespnp@123"

echo "Testing ONVIF Camera at $CAMERA_IP:$CAMERA_PORT"
echo "================================================"

# Test 1: Basic connectivity
echo -e "\n1. Testing basic connectivity..."
curl -s -I http://$CAMERA_IP:$CAMERA_PORT/onvif/device_service | head -3

# Test 2: GetDeviceInformation
echo -e "\n2. Testing GetDeviceInformation..."
cat > /tmp/get_device_info.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" 
               xmlns:tds="http://www.onvif.org/ver10/device/wsdl">
  <soap:Body>
    <tds:GetDeviceInformation/>
  </soap:Body>
</soap:Envelope>
EOF

curl -s -X POST \
  -H "Content-Type: application/soap+xml; charset=utf-8" \
  -H "SOAPAction: \"http://www.onvif.org/ver10/device/wsdl/GetDeviceInformation\"" \
  -d @/tmp/get_device_info.xml \
  http://$CAMERA_IP:$CAMERA_PORT/onvif/device_service | xmllint --format - 2>/dev/null || echo "Install xmllint for formatted output"

# Test 3: Check snapshot endpoint
echo -e "\n3. Testing snapshot endpoint..."
curl -s -I http://$CAMERA_IP:$CAMERA_PORT/snapshot.png | head -3

# Test 4: List all cameras and their endpoints
echo -e "\n4. All virtual cameras:"
echo "======================="
for i in {1..32}; do
  # Get IP from our virtual interfaces
  IP=$(ip addr show onvif-proxy-$i 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d'/' -f1)
  PORT=$((8080 + i))
  if [ -n "$IP" ]; then
    echo "Channel $i: http://$IP:$PORT/onvif/device_service"
  fi
done

echo -e "\n5. RTSP Proxy: rtsp://[camera-ip]:8554/cam/realmonitor?channel=[1-32]&subtype=0&unicast=true&proto=Onvif"
echo "   Snapshot Proxy: http://[camera-ip]:8580/onvifsnapshot/media_service/snapshot?channel=[1-32]&subtype=0"

rm -f /tmp/get_device_info.xml