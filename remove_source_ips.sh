#!/bin/bash
# Bash script to remove source IPs for JMeter testing
# Run with sudo

echo "Removing IP addresses from all interfaces..."

# Remove IP addresses from 192.168.1.2 to 192.168.1.252
for i in {2..252}; do
    ip="192.168.1.$i"
    # Find interface with this IP and remove it
    interface=$(ip addr show | grep "$ip/24" | awk '{print $NF}')
    if [ ! -z "$interface" ]; then
        ip addr del "$ip/24" dev "$interface" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "\033[33mRemoved: $ip from $interface\033[0m"
        else
            echo -e "\033[31mFailed to remove: $ip\033[0m"
        fi
    fi
done

echo "IP address removal complete!"