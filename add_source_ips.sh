#!/bin/bash

# Enhanced IP Alias Setup Script for JMeter Load Testing (Linux)
# Adds IP aliases from 192.168.1.2 to 192.168.1.252 (251 total IPs)
# Must be run with sudo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Configuration
INTERFACE=""
AUTO_DETECT=false
INTERACTIVE=false
LIST_INTERFACES=false
SUBNET_MASK="24"
START_IP=2
END_IP=252

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to show all available interfaces
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
            local ip_info=""
            if [ -n "$ip" ]; then
                ip_info=" ($ip)"
            else
                ip_info=" (No IP)"
            fi
            local desc=$(ethtool -i "$interface" 2>/dev/null | grep "driver" | awk '{print $2}' || echo "Unknown")
            print_color $WHITE "  • $interface$ip_info - Driver: $desc"
        done
        echo ""
    fi
    
    # Show inactive interfaces
    if [ ${#inactive_interfaces[@]} -gt 0 ]; then
        print_color $GRAY "Inactive Interfaces:"
        for interface in "${inactive_interfaces[@]}"; do
            local state=$(ip link show "$interface" | grep -o "state [A-Z]*" | awk '{print $2}')
            local desc=$(ethtool -i "$interface" 2>/dev/null | grep "driver" | awk '{print $2}' || echo "Unknown")
            print_color $GRAY "  • $interface [$state] - Driver: $desc"
        done
        echo ""
    fi
}

# Function to get interface selection from user
get_interface_selection() {
    local show_inactive=${1:-false}
    
    # Get interfaces based on filter
    local interfaces=()
    if [ "$show_inactive" = true ]; then
        interfaces=($(ip link show | grep "^[0-9]" | awk '{print $2}' | sed 's/://' | grep -v lo))
    else
        # Only show UP interfaces
        local all_interfaces=($(ip link show | grep "^[0-9]" | awk '{print $2}' | sed 's/://'))
        for interface in "${all_interfaces[@]}"; do
            if [ "$interface" != "lo" ]; then
                local state=$(ip link show "$interface" | grep -o "state [A-Z]*" | awk '{print $2}')
                if [ "$state" = "UP" ]; then
                    interfaces+=("$interface")
                fi
            fi
        done
    fi
    
    if [ ${#interfaces[@]} -eq 0 ]; then
        print_color $RED "No suitable network interfaces found"
        return 1
    fi
    
    print_color $YELLOW "Select Network Interface:"
    echo ""
    
    # Display interface options
    for i in "${!interfaces[@]}"; do
        local interface="${interfaces[$i]}"
        local ip=$(ip addr show "$interface" | grep "inet " | head -1 | awk '{print $2}' | cut -d'/' -f1)
        local ip_info=""
        if [ -n "$ip" ]; then
            ip_info=" ($ip)"
        else
            ip_info=" (No IP)"
        fi
        
        local state=$(ip link show "$interface" | grep -o "state [A-Z]*" | awk '{print $2}')
        local status_color=$GREEN
        if [ "$state" != "UP" ]; then
            status_color=$YELLOW
        fi
        
        print_color $CYAN "  [$i] "
        echo -n "$interface"
        print_color $GRAY "$ip_info "
        print_color $status_color "[$state]"
        
        # Show additional info
        local desc=$(ethtool -i "$interface" 2>/dev/null | grep "driver" | awk '{print $2}' || echo "Unknown driver")
        print_color $GRAY "      Driver: $desc"
    done
    
    echo ""
    print_color $YELLOW "Options:"
    print_color $GRAY "  [a] Show all interfaces (including inactive)"
    print_color $GRAY "  [r] Refresh interface list"
    print_color $GRAY "  [q] Quit"
    echo ""
    
    while true; do
        read -p "Select interface number, or option (0-$((${#interfaces[@]}-1)), a, r, q): " selection
        
        case "$selection" in
            "a"|"A")
                if [ "$show_inactive" != true ]; then
                    get_interface_selection true
                    return $?
                else
                    print_color $YELLOW "Already showing all interfaces"
                    continue
                fi
                ;;
            "r"|"R")
                print_color $YELLOW "Refreshing interface list..."
                get_interface_selection "$show_inactive"
                return $?
                ;;
            "q"|"Q")
                print_color $YELLOW "Exiting..."
                exit 0
                ;;
            *)
                if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 0 ] && [ "$selection" -lt ${#interfaces[@]} ]; then
                    echo "${interfaces[$selection]}"
                    return 0
                else
                    print_color $RED "Invalid selection. Please try again."
                fi
                ;;
        esac
    done
}

# Function to detect active network interface (enhanced)
detect_interface() {
    # Get active interfaces with default routes
    local default_interfaces=($(ip route | grep default | awk '{print $5}' | sort -u))
    
    if [ ${#default_interfaces[@]} -eq 1 ]; then
        echo "${default_interfaces[0]}"
    elif [ ${#default_interfaces[@]} -gt 1 ]; then
        print_color $YELLOW "Multiple interfaces with default routes found. Auto-selecting the first one with an IP..."
        
        for interface in "${default_interfaces[@]}"; do
            local ip=$(ip addr show "$interface" | grep "inet " | head -1 | awk '{print $2}' | cut -d'/' -f1)
            if [ -n "$ip" ] && [ "$ip" != "127.0.0.1" ]; then
                print_color $GREEN "Selected: $interface ($ip)"
                echo "$interface"
                return 0
            fi
        done
        
        # If no interface with IP found, just return the first one
        print_color $YELLOW "No interface with IP found, selecting: ${default_interfaces[0]}"
        echo "${default_interfaces[0]}"
    else
        # No default routes, try to find any UP interface with IP
        local up_interfaces=($(ip link show | grep "state UP" | awk '{print $2}' | sed 's/://' | grep -v lo))
        
        for interface in "${up_interfaces[@]}"; do
            local ip=$(ip addr show "$interface" | grep "inet " | head -1 | awk '{print $2}' | cut -d'/' -f1)
            if [ -n "$ip" ]; then
                print_color $YELLOW "No default route found, selecting interface with IP: $interface ($ip)"
                echo "$interface"
                return 0
            fi
        done
        
        print_color $RED "Error: No suitable network interfaces found"
        return 1
    fi
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_color $RED "This script must be run with sudo privileges"
        print_color $YELLOW "Usage: sudo $0"
        exit 1
    fi
}

# Function to validate interface
validate_interface() {
    local interface=$1
    if ! ip link show "$interface" &>/dev/null; then
        print_color $RED "Error: Network interface '$interface' not found"
        print_color $YELLOW "Available interfaces:"
        ip link show | grep "^[0-9]" | awk '{print $2}' | sed 's/://' | grep -v lo
        exit 1
    fi
}

# Function to check if IP already exists
ip_exists() {
    local ip=$1
    ip addr show | grep -q "inet $ip/"
}

# Function to add IP alias
add_ip_alias() {
    local ip=$1
    local interface=$2
    
    if ip_exists "$ip"; then
        return 2  # Already exists
    fi
    
    if ip addr add "$ip/$SUBNET_MASK" dev "$interface" 2>/dev/null; then
        return 0  # Success
    else
        return 1  # Error
    fi
}

# Function to test connectivity
test_connectivity() {
    local test_ip=$1
    ping -I "$test_ip" -c 1 -W 2 8.8.8.8 &>/dev/null
}

# Main script starts here
print_color $GREEN "JMeter Load Test - Enhanced IP Alias Setup (Linux)"
print_color $YELLOW "Adding 251 IP aliases (192.168.1.2 - 192.168.1.252)"
echo ""

# Check if running as root
check_root

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interface)
            INTERFACE="$2"
            shift 2
            ;;
        -a|--auto-detect)
            AUTO_DETECT=true
            shift
            ;;
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        -l|--list-interfaces)
            LIST_INTERFACES=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -i, --interface INTERFACE    Specify network interface"
            echo "  -a, --auto-detect           Auto-detect interface"
            echo "      --interactive           Interactive interface selection"
            echo "  -l, --list-interfaces       List all available interfaces"
            echo "  -h, --help                  Show this help"
            echo ""
            echo "Examples:"
            echo "  sudo $0                                    # Auto-detect interface"
            echo "  sudo $0 --interactive                     # Interactive selection"
            echo "  sudo $0 -i eth0                          # Use specific interface"
            echo "  sudo $0 --list-interfaces                # List interfaces only"
            exit 0
            ;;
        *)
            print_color $RED "Unknown option: $1"
            print_color $YELLOW "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Determine interface
if [ -z "$INTERFACE" ]; then
    print_color $YELLOW "Detecting network interface..."
    INTERFACE=$(detect_interface)
fi

validate_interface "$INTERFACE"
print_color $GREEN "Using network interface: $INTERFACE"

# Get current IP to show context
CURRENT_IP=$(ip addr show "$INTERFACE" | grep "inet " | head -1 | awk '{print $2}' | cut -d'/' -f1)
if [ -n "$CURRENT_IP" ]; then
    print_color $CYAN "Current interface IP: $CURRENT_IP"
fi
echo ""

# Confirm operation
read -p "Proceed with adding 251 IP aliases to $INTERFACE? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_color $YELLOW "Operation cancelled by user"
    exit 0
fi

print_color $YELLOW "Starting IP alias addition..."
SUCCESS_COUNT=0
ERROR_COUNT=0
EXISTING_COUNT=0
START_TIME=$(date +%s)

# Add IP aliases
for ((i=START_IP; i<=END_IP; i++)); do
    IP="192.168.1.$i"
    
    add_ip_alias "$IP" "$INTERFACE"
    case $? in
        0)
            ((SUCCESS_COUNT++))
            ;;
        1)
            print_color $RED "  Error adding $IP"
            ((ERROR_COUNT++))
            ;;
        2)
            ((EXISTING_COUNT++))
            ;;
    esac
    
    # Progress indicator every 25 IPs
    if [ $((i % 25)) -eq 0 ]; then
        TOTAL_PROCESSED=$((i - START_IP + 1))
        print_color $CYAN "  Progress: $TOTAL_PROCESSED/251 IPs processed ($SUCCESS_COUNT added, $EXISTING_COUNT existing)"
    fi
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
print_color $GREEN "IP Alias Setup Complete!"
print_color $GREEN "  Successfully added: $SUCCESS_COUNT IPs"
if [ $EXISTING_COUNT -gt 0 ]; then
    print_color $YELLOW "  Already existing: $EXISTING_COUNT IPs"
fi
if [ $ERROR_COUNT -gt 0 ]; then
    print_color $RED "  Errors: $ERROR_COUNT IPs"
else
    print_color $GREEN "  Errors: 0"
fi
print_color $CYAN "  Duration: ${DURATION} seconds"
echo ""

# Verification
print_color $YELLOW "Verifying setup..."
TEST_IPS=("192.168.1.2" "192.168.1.50" "192.168.1.100" "192.168.1.150" "192.168.1.200" "192.168.1.252")
VERIFY_COUNT=0

for test_ip in "${TEST_IPS[@]}"; do
    if ip_exists "$test_ip"; then
        print_color $GREEN "  ✓ $test_ip - OK"
        ((VERIFY_COUNT++))
    else
        print_color $RED "  ✗ $test_ip - Missing"
    fi
done

if [ $VERIFY_COUNT -eq ${#TEST_IPS[@]} ]; then
    echo ""
    print_color $GREEN "✓ Verification successful! All test IPs are configured."
    echo ""
    print_color $CYAN "You can now run your JMeter test with 251 unique source IPs."
    print_color $YELLOW "Remember to run ./remove_source_ips.sh after testing to clean up."
else
    echo ""
    print_color $YELLOW "⚠ Verification found issues. Some IPs may not be properly configured."
fi

# Test connectivity (optional)
echo ""
read -p "Test connectivity with sample IPs? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_color $YELLOW "Testing connectivity..."
    CONNECTIVITY_SUCCESS=false
    
    for test_ip in "192.168.1.2" "192.168.1.100" "192.168.1.252"; do
        if test_connectivity "$test_ip"; then
            print_color $GREEN "  ✓ $test_ip - Connectivity OK"
            CONNECTIVITY_SUCCESS=true
        else
            print_color $RED "  ✗ $test_ip - Connectivity failed"
        fi
    done
    
    if [ "$CONNECTIVITY_SUCCESS" = true ]; then
        print_color $GREEN "  Network connectivity verified!"
    else
        print_color $YELLOW "  Warning: Connectivity tests failed. Check network configuration."
    fi
fi

# Show summary information
echo ""
print_color $GRAY "=== Configuration Summary ==="
print_color $GRAY "Interface: $INTERFACE"
print_color $GRAY "IP Range: 192.168.1.$START_IP - 192.168.1.$END_IP"
print_color $GRAY "Total IPs: 251"
print_color $GRAY "Subnet Mask: /$SUBNET_MASK"
echo ""

# Show commands for manual verification
print_color $YELLOW "Manual verification commands:"
print_color $WHITE "  Check all IPs: ip addr show $INTERFACE | grep '192.168.1.'"
print_color $WHITE "  Test binding: ping -I 192.168.1.2 -c 2 8.8.8.8"
print_color $WHITE "  Remove all: sudo ./remove_source_ips.sh"
print_color $WHITE "  List interfaces: sudo $0 --list-interfaces"
echo ""

print_color $GREEN "Script completed. You can now use JMeter with enhanced multi-IP testing capabilities."

echo ""
print_color $GREEN "Usage Examples:"
print_color $WHITE "  sudo $0                                    # Auto-detect interface"
print_color $WHITE "  sudo $0 --interactive                     # Interactive selection"
print_color $WHITE "  sudo $0 -i eth0                          # Use specific interface"
print_color $WHITE "  sudo $0 --list-interfaces                # List interfaces only"