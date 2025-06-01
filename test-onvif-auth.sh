#!/bin/bash

# Test ONVIF with proper WS-Security authentication
# This simulates what Unifi Protect would do

CAMERA_IP="${1:-192.168.104.170}"
CAMERA_PORT="${2:-8081}"
USERNAME="admin"
PASSWORD="Nespnp@123"

echo "Testing ONVIF authentication for $CAMERA_IP:$CAMERA_PORT"

# Generate WS-Security headers
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
NONCE=$(openssl rand -base64 16)
DIGEST=$(echo -n "${NONCE}${TIMESTAMP}${PASSWORD}" | openssl dgst -sha1 -binary | base64)

cat > /tmp/get_device_info_auth.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope 
    xmlns:soap="http://www.w3.org/2003/05/soap-envelope" 
    xmlns:tds="http://www.onvif.org/ver10/device/wsdl"
    xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
    xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
  <soap:Header>
    <wsse:Security soap:mustUnderstand="true">
      <wsse:UsernameToken>
        <wsse:Username>$USERNAME</wsse:Username>
        <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest">$DIGEST</wsse:Password>
        <wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">$NONCE</wsse:Nonce>
        <wsu:Created>$TIMESTAMP</wsu:Created>
      </wsse:UsernameToken>
    </wsse:Security>
  </soap:Header>
  <soap:Body>
    <tds:GetDeviceInformation/>
  </soap:Body>
</soap:Envelope>
EOF

echo "Request with WS-Security:"
curl -s -X POST \
  -H "Content-Type: application/soap+xml; charset=utf-8" \
  -d @/tmp/get_device_info_auth.xml \
  http://$CAMERA_IP:$CAMERA_PORT/onvif/device_service 2>&1 | head -20

rm -f /tmp/get_device_info_auth.xml