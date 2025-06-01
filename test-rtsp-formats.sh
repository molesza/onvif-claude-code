#!/bin/bash

NVR_IP="192.168.6.201"
USERNAME="admin"
PASSWORD="Nespnp@123"
CHANNEL="1"

echo "Testing different RTSP URL formats for $NVR_IP..."
echo "================================================"

# Common RTSP URL formats
URLS=(
    "rtsp://$USERNAME:$PASSWORD@$NVR_IP:554/cam/realmonitor?channel=$CHANNEL&subtype=0"
    "rtsp://$USERNAME:$PASSWORD@$NVR_IP:554/Streaming/Channels/101"
    "rtsp://$USERNAME:$PASSWORD@$NVR_IP:554/ch0${CHANNEL}/0"
    "rtsp://$USERNAME:$PASSWORD@$NVR_IP:554/live/ch00_0"
    "rtsp://$USERNAME:$PASSWORD@$NVR_IP:554/h264/ch${CHANNEL}/main/av_stream"
    "rtsp://$USERNAME:$PASSWORD@$NVR_IP:554/user=$USERNAME&password=$PASSWORD&channel=$CHANNEL&stream=0.sdp"
    "rtsp://$NVR_IP:554/cam/realmonitor?channel=$CHANNEL&subtype=0&unicast=true&proto=Onvif"
)

for url in "${URLS[@]}"; do
    echo -e "\nTesting: $url"
    timeout 3 ffprobe -v quiet -print_format json -show_streams "$url" 2>&1 | head -5
    if [ $? -eq 0 ]; then
        echo "SUCCESS!"
        break
    fi
done

echo -e "\n\nNote: You may need to check your NVR's documentation for the correct RTSP URL format."
echo "Common brands use different formats:"
echo "- Hikvision: rtsp://user:pass@ip:554/Streaming/Channels/101"
echo "- Dahua: rtsp://user:pass@ip:554/cam/realmonitor?channel=1&subtype=0"
echo "- Generic: rtsp://user:pass@ip:554/ch01/0"