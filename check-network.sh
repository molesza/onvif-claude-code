#!/bin/bash

echo "Network Diagnostics for ONVIF Discovery"
echo "======================================="

echo -e "\n1. Checking if discovery service is listening:"
ss -ulnp 2>/dev/null | grep 3702 || netstat -uln | grep 3702

echo -e "\n2. Checking firewall rules:"
sudo iptables -L -n 2>/dev/null | grep -E "(3702|multicast|239.255)" || echo "Need sudo to check firewall"

echo -e "\n3. Network interfaces with multicast:"
ip maddress show | grep -E "(239.255.255.250|enp8s0)" | head -10

echo -e "\n4. Testing if we can reach Unifi device (common IPs):"
for ip in 192.168.104.1 192.168.104.2 192.168.104.3; do
    ping -c 1 -W 1 $ip >/dev/null 2>&1 && echo "Can reach: $ip" || echo "Cannot reach: $ip"
done

echo -e "\n5. Checking which interface is used for multicast:"
ip route get 239.255.255.250

echo -e "\n6. Camera IPs that should be discoverable:"
ip addr show | grep "onvif-proxy" -A2 | grep "inet " | awk '{print $2}' | cut -d'/' -f1 | head -5

echo -e "\nTroubleshooting tips:"
echo "- Ensure Unifi Protect is on the same network segment (192.168.104.x)"
echo "- Check if multicast is allowed between VLANs if using them"
echo "- Try manually adding one camera in Unifi Protect to test"
echo "- Check Unifi Protect logs for discovery attempts"