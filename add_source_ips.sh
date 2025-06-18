#!/bin/bash
# Script to add source IPs for JMeter testing on Ubuntu
# Run with sudo

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Adding IP addresses for JMeter traffic generation...${NC}"

# Get the primary network interface (excluding loopback)
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)

if [ -z "$INTERFACE" ]; then
    echo -e "${RED}Error: Could not determine network interface${NC}"
    echo "Please manually specify the interface:"
    echo "Available interfaces:"
    ip addr show | grep "^[0-9]" | awk '{print $2}' | sed 's/://'
    exit 1
fi

echo -e "${YELLOW}Using interface: $INTERFACE${NC}"

# Add IP addresses from 192.168.1.10 to 192.168.1.70
for i in {10..70}; do
    IP="192.168.1.$i"
    
    # Check if IP already exists
    if ip addr show $INTERFACE | grep -q "$IP/24"; then
        echo -e "${YELLOW}IP $IP already exists, skipping...${NC}"
        continue
    fi
    
    # Add the IP address
    if ip addr add $IP/24 dev $INTERFACE 2>/dev/null; then
        echo -e "${GREEN}Added: $IP${NC}"
    else
        echo -e "${RED}Failed to add: $IP${NC}"
    fi
done

echo -e "${YELLOW}IP address binding complete!${NC}"
echo -e "${YELLOW}To verify, run: ip addr show $INTERFACE${NC}"
echo -e "${YELLOW}To remove these IPs later, run: sudo ./remove_source_ips.sh${NC}"

# Test connectivity with one of the new IPs
echo -e "${YELLOW}Testing connectivity with 192.168.1.10...${NC}"
if ping -I 192.168.1.10 -c 2 8.8.8.8 >/dev/null 2>&1; then
    echo -e "${GREEN}✓ IP binding successful - JMeter can use these source IPs${NC}"
else
    echo -e "${RED}✗ IP binding may have issues - check network configuration${NC}"
fi
