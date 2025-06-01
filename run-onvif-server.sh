#!/bin/bash

# Script to run the ONVIF server with automatic restart on failure
# Can be run in the background or as a systemd service

cd "$(dirname "$0")"

echo "Starting ONVIF Server..."
echo "Press Ctrl+C to stop"
echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "Shutting down ONVIF server..."
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Run the server
while true; do
    node main.js config.yaml
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo "ONVIF server stopped normally."
        break
    else
        echo "ONVIF server crashed with exit code $EXIT_CODE"
        echo "Restarting in 5 seconds..."
        sleep 5
    fi
done