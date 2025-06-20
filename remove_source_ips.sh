#!/bin/bash

# Enhanced IP Alias Removal Script for JMeter Load Testing (Linux)
# Removes IP aliases from 192.168.1.2 to 192.168.1.252 (251 total IPs)
# Must be run with sudo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
FORCE=false
SKIP_CONFIRMATION=false
INTERFACE=""
LIST_INTERFACES=false
SHOW_DETAILS=false
START_IP=2
END_IP=252

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to show all available interfaces with alias information
show_all_interfaces() {
    print_color $CYAN "Available Network Interfaces:"
    echo ""
    
    # Get all interfaces
    local interfaces=($(ip link show | grep "^[0-9]" | awk '{print $2}' | sed 's/://' | grep -v lo))
    
    if [ ${#interfaces[@]} -eq 0 ]; then
        print_color $RED "No network interfaces found"
        return 1
    fi
    
    # Separate active and inactive interfaces
    local active_interfaces=()
    local inactive_interfaces=()
    
    for interface in "${interfaces[@]}"; do
        local state=$(ip link show "$interface" | grep -o "state [A-Z]*" | awk '{print $2}')
        if [ "$state" = "UP" ]; then
            active_interfaces+=("$interface")
        else
            inactive_interfaces+=("$interface")
        fi
    done
    
    # Show active interfaces
    if [ ${#active_interfaces[@]} -gt 0 ]; then
        print_color $GREEN "Active Interfaces:"
        for interface in "${active_interfaces[@]}"; do
            local ip=$(ip addr show "$interface" | grep "inet " | head -1 | awk '{print $2}' | cut -d'/' -f1)
            local alias_count=$(ip addr show "$interface" | grep -c "inet 192\.168\.1\.[0-9]")
            local ip_info=""
            if [ -n "$ip" ] && [ "$ip" != "127.0.0.1" ]; then
                ip_info=" ($ip)"
            else
                ip_info=" (No IP)"
            fi
            local alias_info=""
            if [ $alias_count -gt 0 ]; then
                alias_info=" [$alias_count aliases]"
            fi
            local driver=$(ethtool -i "$interface" 2>/dev/null | grep "driver" | awk '{print $2}' || echo "Unknown")
            print_color $WHITE "  • $interface$ip_info$alias_info - Driver: $driver"
        done
        echo ""
    fi
    
    # Show inactive interfaces
    if [ ${#inactive_interfaces[@]} -gt 0 ]; then
        print_color $GRAY "Inactive Interfaces:"
        for interface in "${inactive_interfaces[@]}"; do
            local state=$(ip link show "$interface" | grep -o "state [A-Z]*" | awk '{print $2}')
            local driver=$(ethtool -i "$interface" 2>/dev/null | grep "driver" | awk '{print $2}' || echo "Unknown")
            print_color $GRAY "  • $interface [$state] - Driver: $driver"
        done
        echo ""
    fi
}

# Function to find interfaces with IP aliases in our range
find_interfaces_with_aliases() {
    local interfaces_with_aliases=()
    local all_interfaces=($(ip link show | grep "^[0-9]" | awk '{print $2}' | sed 's/://' | grep -v lo))
    
    for interface in "${all_interfaces[@]}"; do
        local alias_count=0
        for ((i=START_IP; i<=END_IP; i++)); do
            local ip="192.168.1.$i"
            if ip addr show "$interface" | grep -q "inet $ip/"; then
                ((alias_count++))
            fi
        done
        
        if [ $alias_count -gt 0 ]; then
            interfaces_with_aliases+=("$interface:$alias_count")
        fi
    done
    
    echo "${interfaces_with_aliases[@]}"
}
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_color $RED "This script must be run with sudo privileges"
        print_color $YELLOW "Usage: sudo $0 [OPTIONS]"
        exit 1
    fi
}

# Function to check if IP exists
ip_exists() {
    local ip=$1
    ip addr show | grep -q "inet $ip/"
}

# Function to get interface for IP
get_interface_for_ip() {
    local ip=$1
    ip addr show | grep "inet $ip/" | awk '{print $NF}' | head -1
}

# Function to remove IP alias
remove_ip_alias() {
    local ip=$1
    local interface=$2
    
    if ip addr del "$ip/24" dev "$interface" 2>/dev/null; then
        return 0  # Success
    else
        return 1  # Error
    fi
}

# Main script starts here
print_color $RED "JMeter Load Test - Enhanced IP Alias Removal (Linux)"
print_color $YELLOW "Removing 251 IP aliases (192.168.1.2 - 192.168.1.252)"
echo ""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE=true
            shift
            ;;
        -y|--yes)
            SKIP_CONFIRMATION=true
            shift
            ;;
        -i|--interface)
            INTERFACE="$2"
            shift 2
            ;;
        -l|--list-interfaces)
            LIST_INTERFACES=true
            shift
            ;;
        -d|--show-details)
            SHOW_DETAILS=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -f, --force                 Force removal even if errors occur"
            echo "  -y, --yes                   Skip confirmation prompt"
            echo "  -i, --interface INTERFACE   Remove only from specific interface"
            echo "  -l, --list-interfaces       List interfaces with IP aliases"
            echo "  -d, --show-details         Show detailed removal process"
            echo "  -h, --help                  Show this help"
            echo ""
            echo "Examples:"
            echo "  sudo $0                                    # Remove from all interfaces"
            echo "  sudo $0 -i eth0                          # Remove from specific interface"
            echo "  sudo $0 --show-details                   # Show detailed removal"
            echo "  sudo $0 --list-interfaces                # List interfaces with aliases"
            echo "  sudo $0 -f -y                           # Force remove without prompts"
            exit 0
            ;;
        *)
            print_color $RED "Unknown option: $1"
            print_color $YELLOW "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Check if running as root
check_root

# Handle list interfaces option
if [ "$LIST_INTERFACES" = true ]; then
    show_all_interfaces
    exit 0
fi

# Find existing IP aliases in our range
print_color $YELLOW "Scanning for existing IP aliases..."

if [ -n "$INTERFACE" ]; then
    # Check specific interface
    if ! ip link show "$INTERFACE" &>/dev/null; then
        print_color $RED "Error: Network interface '$INTERFACE' not found"
        print_color $YELLOW "Available interfaces:"
        show_all_interfaces
        exit 1
    fi
    
    print_color $CYAN "Scanning interface: $INTERFACE"
    EXISTING_IPS=()
    IP_INTERFACES=()
    
    for ((i=START_IP; i<=END_IP; i++)); do
        IP="192.168.1.$i"
        if ip addr show "$INTERFACE" | grep -q "inet $IP/"; then
            EXISTING_IPS+=("$IP")
            IP_INTERFACES+=("$INTERFACE")
        fi
    done
else
    # Scan all interfaces
    INTERFACES_WITH_ALIASES=($(find_interfaces_with_aliases))
    
    if [ ${#INTERFACES_WITH_ALIASES[@]} -eq 0 ]; then
        print_color $GREEN "No IP aliases found in the range 192.168.1.$START_IP-$END_IP on any interface"
        print_color $CYAN "Nothing to remove."
        exit 0
    fi
    
    if [ "$SHOW_DETAILS" = true ]; then
        print_color $CYAN "Interfaces with IP aliases:"
        for interface_info in "${INTERFACES_WITH_ALIASES[@]}"; do
            IFS=':' read -r interface_name alias_count <<< "$interface_info"
            local state=$(ip link show "$interface_name" | grep -o "state [A-Z]*" | awk '{print $2}')
            print_color $WHITE "  • $interface_name [$state] - $alias_count aliases"
        done
        echo ""
    fi
    
    # Collect all IPs from all interfaces
    EXISTING_IPS=()
    IP_INTERFACES=()
    
    for ((i=START_IP; i<=END_IP; i++)); do
        IP="192.168.1.$i"
        INTERFACE_FOUND=$(get_interface_for_ip "$IP")
        if [ -n "$INTERFACE_FOUND" ]; then
            EXISTING_IPS+=("$IP")
            IP_INTERFACES+=("$INTERFACE_FOUND")
        fi
    done
fi

if [ ${#EXISTING_IPS[@]} -eq 0 ]; then
    print_color $GREEN "No IP aliases found in the range 192.168.1.$START_IP-$END_IP"
    print_color $CYAN "Nothing to remove."
    exit 0
fi

print_color $CYAN "Found ${#EXISTING_IPS[@]} IP aliases to remove:"

# Show sample IPs (not all 251 to avoid clutter)
if [ ${#EXISTING_IPS[@]} -le 10 ]; then
    for i in "${!EXISTING_IPS[@]}"; do
        print_color $WHITE "  - ${EXISTING_IPS[$i]} (${IP_INTERFACES[$i]})"
    done
else
    print_color $WHITE "  - ${EXISTING_IPS[0]} (${IP_INTERFACES[0]}) (first)"
    print_color $GRAY "  - ... $((${#EXISTING_IPS[@]} - 2)) more IPs ..."
    print_color $WHITE "  - ${EXISTING_IPS[-1]} (${IP_INTERFACES[-1]}) (last)"
fi

echo ""

# Confirmation prompt
if [ "$SKIP_CONFIRMATION" = false ] && [ "$FORCE" = false ]; then
    read -p "Are you sure you want to remove all ${#EXISTING_IPS[@]} IP aliases? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_color $YELLOW "Operation cancelled by user."
        exit 0
    fi
fi

print_color $YELLOW "Starting IP alias removal..."
SUCCESS_COUNT=0
ERROR_COUNT=0
START_TIME=$(date +%s)

# Remove each IP alias
for i in "${!EXISTING_IPS[@]}"; do
    IP="${EXISTING_IPS[$i]}"
    INTERFACE_NAME="${IP_INTERFACES[$i]}"
    
    if remove_ip_alias "$IP" "$INTERFACE_NAME"; then
        ((SUCCESS_COUNT++))
        
        if [ "$SHOW_DETAILS" = true ]; then
            print_color $GREEN "  Removed $IP from $INTERFACE_NAME"
        fi
    else
        print_color $RED "  Error removing $IP from $INTERFACE_NAME"
        ((ERROR_COUNT++))
        
        if [ "$FORCE" = false ]; then
            print_color $YELLOW "  Use --force flag to continue despite errors"
        fi
    fi
    
    # Progress indicator every 25 IPs
    CURRENT=$((i + 1))
    if [ $((CURRENT % 25)) -eq 0 ]; then
        print_color $CYAN "  Progress: $CURRENT/${#EXISTING_IPS[@]} IPs processed ($SUCCESS_COUNT removed)"
    fi
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
print_color $GREEN "IP Alias Removal Complete!"
print_color $GREEN "  Successfully removed: $SUCCESS_COUNT IPs"
if [ $ERROR_COUNT -gt 0 ]; then
    print_color $RED "  Errors: $ERROR_COUNT IPs"
else
    print_color $GREEN "  Errors: 0"
fi
print_color $CYAN "  Duration: ${DURATION} seconds"
echo ""

# Verification
print_color $YELLOW "Verifying removal..."
TEST_IPS=("192.168.1.2" "192.168.1.50" "192.168.1.100" "192.168.1.150" "192.168.1.200" "192.168.1.252")
REMAINING_COUNT=0

for test_ip in "${TEST_IPS[@]}"; do
    if ip_exists "$test_ip"; then
        print_color $RED "  ✗ $test_ip - Still exists"
        ((REMAINING_COUNT++))
    else
        print_color $GREEN "  ✓ $test_ip - Removed"
    fi
done

if [ $REMAINING_COUNT -eq 0 ]; then
    echo ""
    print_color $GREEN "✓ Verification successful! All test IPs have been removed."
    echo ""
    print_color $CYAN "Network configuration has been restored to original state."
else
    echo ""
    print_color $YELLOW "⚠ Verification found issues. Some IPs may still exist."
    print_color $YELLOW "You may need to manually remove remaining IPs."
fi

# Final comprehensive scan
print_color $YELLOW "Performing final comprehensive scan..."

if [ -n "$INTERFACE" ]; then
    # Scan specific interface
    FINAL_SCAN=()
    for ((i=START_IP; i<=END_IP; i++)); do
        IP="192.168.1.$i"
        if ip addr show "$INTERFACE" | grep -q "inet $IP/"; then
            FINAL_SCAN+=("$IP ($INTERFACE)")
        fi
    done
else
    # Scan all interfaces
    FINAL_SCAN=()
    INTERFACES_WITH_ALIASES=($(find_interfaces_with_aliases))
    
    for interface_info in "${INTERFACES_WITH_ALIASES[@]}"; do
        IFS=':' read -r interface_name alias_count <<< "$interface_info"
        for ((i=START_IP; i<=END_IP; i++)); do
            IP="192.168.1.$i"
            if ip addr show "$interface_name" | grep -q "inet $IP/"; then
                FINAL_SCAN+=("$IP ($interface_name)")
            fi
        done
    done
fi

if [ ${#FINAL_SCAN[@]} -eq 0 ]; then
    print_color $GREEN "✓ Final scan complete: No IP aliases remain in range 192.168.1.$START_IP-$END_IP"
else
    print_color $YELLOW "⚠ Final scan found ${#FINAL_SCAN[@]} remaining IP aliases:"
    if [ ${#FINAL_SCAN[@]} -le 5 ]; then
        for remaining_ip in "${FINAL_SCAN[@]}"; do
            print_color $RED "  - $remaining_ip"
        done
    else
        print_color $RED "  - ${FINAL_SCAN[0]} ... and $((${#FINAL_SCAN[@]} - 1)) more"
    fi
    
    echo ""
    print_color $YELLOW "To remove remaining IPs manually:"
    print_color $WHITE "  sudo ip addr del <IP>/24 dev <INTERFACE>"
    print_color $WHITE "Example: sudo ip addr del 192.168.1.2/24 dev eth0"
    echo ""
    print_color $YELLOW "Or run this script with options:"
    print_color $WHITE "  sudo $0 --force                     # Force removal"
    print_color $WHITE "  sudo $0 -i <interface>              # Target specific interface"
    print_color $WHITE "  sudo $0 --show-details              # Show detailed process"
fi

# Show network interface status
echo ""
print_color $GRAY "=== Current Network Interface Status ==="
if [ -n "$INTERFACE" ]; then
    # Show status for specific interface
    IP_COUNT=$(ip addr show "$INTERFACE" | grep -c "inet 192.168.1.")
    STATE=$(ip link show "$INTERFACE" | grep -o "state [A-Z]*" | awk '{print $2}')
    print_color $GRAY "Interface $INTERFACE [$STATE]: $IP_COUNT IPs in 192.168.1.x range"
else
    # Show status for all interfaces
    INTERFACES=$(ip link show | grep "^[0-9]" | awk '{print $2}' | sed 's/://' | grep -v lo)
    for interface in $INTERFACES; do
        IP_COUNT=$(ip addr show "$interface" | grep -c "inet 192.168.1.")
        if [ $IP_COUNT -gt 0 ]; then
            STATE=$(ip link show "$interface" | grep -o "state [A-Z]*" | awk '{print $2}')
            print_color $GRAY "Interface $interface [$STATE]: $IP_COUNT IPs in 192.168.1.x range"
        fi
    done
fi
echo ""

# Cleanup suggestions
if [ ${#FINAL_SCAN[@]} -gt 0 ]; then
    print_color $YELLOW "=== Cleanup Suggestions ==="
    print_color $WHITE "1. Run with --force flag: sudo $0 --force"
    print_color $WHITE "2. Target specific interface: sudo $0 -i <interface>"
    print_color $WHITE "3. Show detailed process: sudo $0 --show-details"
    print_color $WHITE "4. Restart network manager: sudo systemctl restart NetworkManager"
    print_color $WHITE "5. Restart specific interface: sudo ip link set <interface> down && sudo ip link set <interface> up"
    print_color $WHITE "6. Reboot system (last resort)"
    echo ""
fi

print_color $GREEN "Cleanup completed. Check the final scan results above."

echo ""
print_color $GREEN "Usage Examples:"
print_color $WHITE "  sudo $0                                    # Remove from all interfaces"
print_color $WHITE "  sudo $0 -i eth0                          # Remove from specific interface"
print_color $WHITE "  sudo $0 --show-details                   # Show detailed removal"
print_color $WHITE "  sudo $0 --list-interfaces                # List interfaces with aliases"
print_color $WHITE "  sudo $0 -f -y                           # Force remove without prompts"