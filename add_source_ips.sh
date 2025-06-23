#!/bin/bash
# Bash script to add source IPs for JMeter testing
# Run with sudo

# Get the active network interface (modify if needed)
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
echo "Adding IP addresses to interface: $INTERFACE"

# Add IP addresses from 192.168.1.2 to 192.168.1.252
for i in {2..252}; do
    ip="192.168.1.$i"
    ip addr add "$ip/24" dev "$INTERFACE" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "\033[32mAdded: $ip\033[0m"
    else
        echo -e "\033[31mFailed to add: $ip\033[0m"
    fi
done

echo "IP address binding complete!"
echo "To remove these IPs later, run: sudo ./remove_source_ips.sh"