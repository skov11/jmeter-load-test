#!/bin/bash
# Script to remove source IPs after JMeter testing on Ubuntu
# Run with sudo

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Removing IP addresses after JMeter testing...${NC}"

# Get the primary network interface
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)

if [ -z "$INTERFACE" ]; then
    echo -e "${RED}Error: Could not determine network interface${NC}"
    exit 1
fi

echo -e "${YELLOW}Using interface: $INTERFACE${NC}"

# Remove IP addresses from 192.168.1.10 to 192.168.1.70
for i in {10..70}; do
    IP="192.168.1.$i"
    
    # Check if IP exists before trying to remove
    if ip addr show $INTERFACE | grep -q "$IP/24"; then
        if ip addr del $IP/24 dev $INTERFACE 2>/dev/null; then
            echo -e "${GREEN}Removed: $IP${NC}"
        else
            echo -e "${RED}Failed to remove: $IP${NC}"
        fi
    else
        echo -e "${YELLOW}IP $IP not found, skipping...${NC}"
    fi
done

echo -e "${YELLOW}IP address removal complete!${NC}"
echo -e "${YELLOW}To verify, run: ip addr show $INTERFACE${NC}"
