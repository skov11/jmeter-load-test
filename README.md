# Enhanced JMeter Load Testing Project

This JMeter test plan creates realistic web browsing traffic from multiple source IPs to test firewall performance, load balancing, and network security systems under authentic conditions.

## 🚀 Key Features

- **251 concurrent source IPs** (192.168.1.2-252) for comprehensive multi-source testing
- **50 concurrent users** browsing simultaneously with realistic behavior patterns
- **2000+ diverse websites** across multiple categories (social media, e-commerce, news, tech, education, cloud services, etc.)
- **20+ different browser profiles** with realistic headers (User-Agent, screen resolution, DNT settings, etc.)
- **HTTPS and HTTP traffic** with proper SSL/TLS encryption
- **200+ variable search terms** (realistic search queries from everyday items to technical products)
- **Enhanced interface management** with intelligent detection and selection
- **Cross-platform support** (Windows PowerShell and Linux Bash)

## 📊 Traffic Simulation Details

### Advanced Human-like Browsing Patterns

Each simulated user follows sophisticated probability-based behavior with conditional logic:

**Session Probabilities:**

- 80% chance of visiting category/product pages
- 60% chance of using search functionality
- 40% chance of viewing detailed product pages
- 30% chance of visiting information pages (about, contact, etc.)
- 20% chance of simulating shopping cart actions (add to cart, view cart)
- 15% chance of early session abandonment (realistic user dropout)

**Realistic Timing Patterns:**

- Homepage visit: 15-35 seconds reading time
- Category/product browsing: 33-68 seconds with navigation delays + AJAX requests
- Search functionality: 32-65 seconds including typing simulation with varied search terms
- Detailed page viewing: 51-117 seconds for thorough reading
- Shopping cart simulation: 15-35 seconds cart review for users who add items
- Information page visit: 18-43 seconds quick scan
- Session breaks: 2-7 minutes between complete browsing cycles

**Device-Specific Behavior:**

- **Mobile users**: 30% shorter sessions, max 3 pages, faster interactions
- **Desktop users**: Full sessions, max 5 pages, longer reading times
- **Automatic device detection** based on User-Agent strings

## 📁 Project Structure

```
jmeter-load-test/
├── browsing_test.jmx           # Main JMeter test plan
├── source_ips.csv              # 251 source IP addresses (192.168.1.2-252)
├── user_agents.csv             # 20+ browser profiles with realistic headers
├── websites.csv                # 2000+ diverse websites across categories
├── add_source_ips.ps1          # Enhanced Windows IP management (PowerShell)
├── remove_source_ips.ps1       # Enhanced Windows IP cleanup (PowerShell)
├── add_source_ips.sh           # Enhanced Linux IP management (Bash)
├── remove_source_ips.sh        # Enhanced Linux IP cleanup (Bash)
└── README.md                   # This documentation
```

## 🔧 Prerequisites

### Java Installation

**Windows & Linux:**

- Download Java 8 or higher from [Oracle](https://www.oracle.com/java/technologies/downloads/) or [OpenJDK](https://adoptium.net/)
- Verify installation: `java -version`

### JMeter Installation

**Windows:**

1. Download [Apache JMeter](https://jmeter.apache.org/download_jmeter.cgi) binary zip
2. Extract to `C:\jmeter\`

**Linux (Ubuntu/Debian):**

```bash
sudo apt update
sudo apt install openjdk-11-jdk
cd /opt
sudo wget https://downloads.apache.org//jmeter/binaries/apache-jmeter-5.6.3.tgz
sudo tar -xzf apache-jmeter-5.6.3.tgz
sudo mv apache-jmeter-5.6.3 jmeter
sudo chown -R $USER:$USER /opt/jmeter
```

## 🌐 Enhanced IP Alias Management

### Windows PowerShell Scripts

#### `add_source_ips.ps1` - Enhanced IP Addition

**Usage Examples:**

```powershell
# Auto-detect interface (default behavior)
.\add_source_ips.ps1

# Interactive interface selection with detailed menu
.\add_source_ips.ps1 -Interactive

# Specify interface directly
.\add_source_ips.ps1 -InterfaceName "Wi-Fi"

# List all available interfaces and exit
.\add_source_ips.ps1 -ListInterfaces

# Auto-detect with explicit flag
.\add_source_ips.ps1 -AutoDetect
```

**Parameters:**

- `-InterfaceName "Name"` - Specify network interface directly
- `-Interactive` - Launch interactive interface selection menu
- `-ListInterfaces` - Display all available interfaces with details and exit
- `-AutoDetect` - Explicitly use auto-detection (default behavior)

**Features:**

- **Smart Auto-Detection**: Automatically selects best interface with IP address
- **Interactive Selection**: Browse interfaces with detailed information (IP, status, description)
- **Interface Validation**: Shows warnings for inactive interfaces
- **Progress Tracking**: Real-time progress indicators during IP addition
- **Connectivity Testing**: Optional connectivity verification with sample IPs
- **Comprehensive Verification**: Multi-level verification of IP configuration

#### `remove_source_ips.ps1` - Enhanced IP Removal

**Usage Examples:**

```powershell
# Remove from all interfaces (default)
.\remove_source_ips.ps1

# Remove from specific interface only
.\remove_source_ips.ps1 -InterfaceName "Ethernet"

# Show detailed removal process
.\remove_source_ips.ps1 -ShowDetails

# List interfaces with alias counts
.\remove_source_ips.ps1 -ListInterfaces

# Force removal without prompts
.\remove_source_ips.ps1 -Force -SkipConfirmation
```

**Parameters:**

- `-InterfaceName "Name"` - Remove aliases only from specific interface
- `-ShowDetails` - Display detailed removal process (which IP from which interface)
- `-ListInterfaces` - Show all interfaces with alias counts and exit
- `-Force` - Continue removal even if errors occur
- `-SkipConfirmation` - Skip confirmation prompts

**Features:**

- **Interface-Specific Removal**: Target individual interfaces
- **Smart Interface Detection**: Automatically finds interfaces with aliases
- **Detailed Progress**: Shows exactly which IP is removed from which interface
- **Comprehensive Scanning**: Final verification across all interfaces
- **Enhanced Error Handling**: Specific troubleshooting guidance

### Linux Bash Scripts

#### `add_source_ips.sh` - Enhanced IP Addition

**Usage Examples:**

```bash
# Auto-detect interface (default behavior)
sudo ./add_source_ips.sh

# Interactive interface selection with detailed menu
sudo ./add_source_ips.sh --interactive

# Specify interface directly
sudo ./add_source_ips.sh -i eth0

# List all available interfaces and exit
sudo ./add_source_ips.sh --list-interfaces

# Auto-detect with explicit flag
sudo ./add_source_ips.sh --auto-detect
```

**Parameters:**

- `-i, --interface INTERFACE` - Specify network interface directly
- `--interactive` - Launch interactive interface selection menu
- `-l, --list-interfaces` - Display all available interfaces with details and exit
- `-a, --auto-detect` - Explicitly use auto-detection (default behavior)
- `-h, --help` - Show help and usage examples

**Features:**

- **Color-Coded Output**: Active interfaces in green, inactive in yellow/gray
- **Driver Information**: Shows network driver for each interface
- **State Detection**: Displays interface state (UP/DOWN) with color coding
- **Smart Auto-Detection**: Prioritizes interfaces with default routes and IP addresses
- **Interactive Menu**: Browse and select from available interfaces
- **Enhanced Validation**: Warns about inactive interfaces before proceeding

#### `remove_source_ips.sh` - Enhanced IP Removal

**Usage Examples:**

```bash
# Remove from all interfaces (default)
sudo ./remove_source_ips.sh

# Remove from specific interface only
sudo ./remove_source_ips.sh -i eth0

# Show detailed removal process
sudo ./remove_source_ips.sh --show-details

# List interfaces with alias counts
sudo ./remove_source_ips.sh --list-interfaces

# Force removal without prompts
sudo ./remove_source_ips.sh -f -y
```

**Parameters:**

- `-i, --interface INTERFACE` - Remove aliases only from specific interface
- `-d, --show-details` - Display detailed removal process
- `-l, --list-interfaces` - Show all interfaces with alias counts and exit
- `-f, --force` - Continue removal even if errors occur
- `-y, --yes` - Skip confirmation prompts
- `-h, --help` - Show help and usage examples

**Features:**

- **Interface-Specific Operations**: Can target single interface or scan all
- **Enhanced Progress Tracking**: Shows removal progress with interface names
- **Comprehensive Final Scan**: Verifies complete removal across all interfaces
- **Color-Coded Status**: Clear visual feedback for all operations
- **Detailed Interface Information**: Shows driver, state, and alias counts

## 🚀 Quick Start Guide

### 1. Setup IP Aliases

**Windows (Run PowerShell as Administrator):**

```powershell
# Interactive setup (recommended for first-time users)
.\add_source_ips.ps1 -Interactive

# Quick auto-setup
.\add_source_ips.ps1
```

**Linux (Run with sudo):**

```bash
# Interactive setup (recommended for first-time users)
sudo ./add_source_ips.sh --interactive

# Quick auto-setup
sudo ./add_source_ips.sh
```

### 2. Verify IP Configuration

**Windows:**

```powershell
# List interfaces with alias information
.\add_source_ips.ps1 -ListInterfaces

# Test connectivity
ping -S 192.168.1.2 8.8.8.8
```

**Linux:**

```bash
# List interfaces with alias information
sudo ./add_source_ips.sh --list-interfaces

# Test connectivity
ping -I 192.168.1.2 -c 2 8.8.8.8
```

### 3. Run JMeter Test

**GUI Mode (for development/testing):**

```bash
# Windows
C:\jmeter\apache-jmeter-X.X\bin\jmeter.bat

# Linux
/opt/jmeter/bin/jmeter

# Then: File → Open → browsing_test.jmx
```

**Command Line Mode (for production testing):**

```bash
# Windows
C:\jmeter\apache-jmeter-X.X\bin\jmeter.bat -n -t browsing_test.jmx -l results.jtl

# Linux
/opt/jmeter/bin/jmeter -n -t browsing_test.jmx -l results.jtl
```

### 4. Cleanup (IMPORTANT)

**Windows:**

```powershell
# Remove all IP aliases
.\remove_source_ips.ps1

# Remove from specific interface
.\remove_source_ips.ps1 -InterfaceName "Wi-Fi"
```

**Linux:**

```bash
# Remove all IP aliases
sudo ./remove_source_ips.sh

# Remove from specific interface
sudo ./remove_source_ips.sh -i eth0
```

## 📈 Test Configuration

### Default Settings

- **Concurrent Users**: 50 simulated users
- **Source IPs**: 251 unique addresses (192.168.1.2-252)
- **Ramp-up Period**: 600 seconds (10 minutes)
- **Test Duration**: 20-35 minutes per user (3 browsing cycles)
- **Total Requests**: ~300-750 HTTP requests (varies by user probability paths)
- **Request Rate**: 1-4 requests per minute per user (conservative, human-like)

### Customizable Parameters

You can modify these in the JMeter test plan:

- Number of threads (users)
- Ramp-up period
- Loop count (browsing cycles)
- Target websites (edit websites.csv)
- User agents (edit user_agents.csv)
- Source IP range (edit source_ips.csv)

## 🔍 Monitoring and Results

### Real-time Monitoring

- **GUI Mode**: Watch Summary Report for live statistics
- **Command Line**: Monitor console output for progress
- **Firewall Logs**: Check firewall logs for multi-IP traffic

### Results Analysis

```bash
# Generate HTML report (Windows)
C:\jmeter\apache-jmeter-X.X\bin\jmeter.bat -g results.jtl -o report

# Generate HTML report (Linux)
/opt/jmeter/bin/jmeter -g results.jtl -o report
```

### Key Metrics to Monitor

- Response times across different source IPs
- Error rates and failure patterns
- Throughput (requests/second) per IP
- Firewall performance and connection handling
- Load balancer distribution patterns
- Network security system behavior

## 🛠️ Troubleshooting

### Common Issues and Solutions

#### "Cannot bind to source IP"

**Windows:**

```powershell
# Check IP aliases
ipconfig /all

# List interfaces with aliases
.\add_source_ips.ps1 -ListInterfaces

# Try specific interface
.\add_source_ips.ps1 -InterfaceName "YourInterface"
```

**Linux:**

```bash
# Check IP aliases
ip addr show

# List interfaces with aliases
sudo ./add_source_ips.sh --list-interfaces

# Try specific interface
sudo ./add_source_ips.sh -i eth0
```

#### CSV File Errors

- Ensure all CSV files are in the same directory as the .jmx file
- Check file names match exactly (case-sensitive)
- Verify CSV files are properly formatted with headers

#### Permission Errors

- **Windows**: Run PowerShell as Administrator
- **Linux**: Use sudo for all IP management scripts
- Check Windows firewall/antivirus blocking JMeter

#### High CPU Usage

- Reduce number of threads for initial testing
- Use command line mode instead of GUI for production testing
- Monitor system resources during testing

#### Network Connectivity Issues

- Verify internet connection
- Test basic connectivity: `ping 8.8.8.8`
- Check DNS resolution: `nslookup www.google.com`
- Ensure firewall allows outbound connections

### Advanced Troubleshooting

#### Interface Detection Issues

**Windows:**

```powershell
# Show detailed interface information
Get-NetAdapter | Format-Table Name, Status, InterfaceDescription
Get-NetIPAddress | Where-Object {$_.IPAddress -like "192.168.1.*"}
```

**Linux:**

```bash
# Show detailed interface information
ip link show
ip addr show
ethtool -i eth0  # Replace eth0 with your interface
```

#### Network Performance Issues

- Increase JVM heap size: `export JVM_ARGS="-Xms1g -Xmx4g"`
- Use fewer concurrent users initially
- Monitor network bandwidth usage
- Check for network congestion

## ⚙️ Advanced Configuration

### Custom Target Configuration

Edit `browsing_test.jmx` to change target settings:

```xml
<stringProp name="Argument.value">your-target-host</stringProp>
<stringProp name="Argument.value">80</stringProp>
<stringProp name="Argument.value">http</stringProp>
```

### Custom IP Ranges

Edit `source_ips.csv` and update scripts with new IP range:

- Modify `START_IP` and `END_IP` variables in scripts
- Ensure IP range doesn't conflict with existing network devices
- Update subnet mask if needed

### Performance Tuning

For high-load testing:

```bash
# Increase system limits (Linux)
echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf

# Increase JMeter heap
export JVM_ARGS="-Xms2g -Xmx8g"
```

## 🔒 Security and Best Practices

### Safety Guidelines

- **Only test your own infrastructure** or with explicit permission
- **Use isolated test networks** when possible
- **Monitor system resources** to avoid overloading test machines
- **Always remove IP aliases** after testing to avoid network conflicts
- **Start with small tests** (10 users) before scaling up

### Network Considerations

- Ensure adequate bandwidth for generated traffic
- Monitor firewall and security device performance
- Plan for cleanup in case of unexpected termination
- Consider impact on production networks

### Responsible Testing

- Respect rate limits and website terms of service
- Use test targets or your own infrastructure when possible
- Monitor and control test intensity
- Have emergency stop procedures ready

## 📊 What This Test Evaluates

This comprehensive load testing framework helps evaluate:

- **Connection Handling**: How systems manage multiple simultaneous connections
- **SSL/TLS Performance**: Inspection capabilities with encrypted traffic
- **NAT and Connection Tracking**: Performance with multiple source IPs
- **DNS Resolution**: Handling diverse domain queries
- **Content Filtering**: Web security feature effectiveness
- **Load Balancing**: Distribution across multiple users and IPs
- **Geographic Simulation**: Varied User-Agent and language patterns
- **Session Management**: State persistence and tracking
- **Network Security**: Behavior under realistic traffic patterns
- **Scalability**: Performance under graduated load increases

## 🎯 Use Cases

This testing framework is ideal for:

- **Firewall Performance Testing**: Multi-IP traffic simulation
- **Load Balancer Validation**: Distribution pattern analysis
- **Network Security Assessment**: Real-world traffic simulation
- **Capacity Planning**: Determining system limits
- **Performance Benchmarking**: Baseline establishment
- **Regression Testing**: Validating system changes
- **Stress Testing**: Identifying breaking points
- **Security Testing**: Evaluating protection mechanisms

## 📝 Version History

### Enhanced Version Features

- **251 source IPs** (expanded from 60)
- **Intelligent interface detection** with auto-selection
- **Interactive interface selection** menus
- **Enhanced error handling** and troubleshooting
- **Cross-platform compatibility** improvements
- **Detailed progress tracking** and verification
- **Interface-specific operations** for targeted testing
- **Comprehensive documentation** and examples

---

**⚠️ Important Reminders:**

1. Always run IP management scripts as Administrator (Windows) or with sudo (Linux)
2. Remove IP aliases after testing: `.\remove_source_ips.ps1` or `sudo ./remove_source_ips.sh`
3. The 251 IP aliases are temporary and should be cleaned up
4. Test responsibly and only against your own infrastructure
5. Monitor system resources during testing to avoid overload

**🚀 Ready to simulate realistic, multi-source network traffic for comprehensive system testing!**
