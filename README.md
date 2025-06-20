# Enhanced JMeter Load Testing Project

This JMeter test plan creates realistic web browsing traffic from multiple source IPs to test firewall performance, load balancing, and network security systems under authentic conditions.

## 🚀 Key Features

- **Up to 250 concurrent source IPs** (192.168.1.2-252) for comprehensive multi-source testing
- **50 concurrent users** browsing simultaneously with realistic behavior patterns
- **2000+ diverse websites** across multiple categories (social media, e-commerce, news, tech, education, cloud services, etc.)
- **20+ different browser profiles** with realistic headers (User-Agent, screen resolution, DNT settings, etc.)
- **HTTPS and HTTP traffic** with proper SSL/TLS encryption
- **200+ variable search terms** (realistic search queries from everyday items to technical products)
- **Simple, reliable IP management** with automatic interface detection
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
├── add_source_ips.ps1          # Windows IP management (PowerShell)
├── remove_source_ips.ps1       # Windows IP cleanup (PowerShell)
├── add_source_ips.sh           # Linux IP management (Bash)
├── remove_source_ips.sh        # Linux IP cleanup (Bash)
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

## 🌐 Simple IP Alias Management

### Windows PowerShell Scripts

#### `add_source_ips.ps1` - Add IP Aliases

**Usage:**

```powershell
# Run as Administrator
.\add_source_ips.ps1
```

**Features:**

- **Automatic Interface Detection**: Finds the first active non-loopback interface
- **Progress Reporting**: Shows which IPs are being added
- **Error Handling**: Reports any IPs that fail to add
- **Duplicate Detection**: Skips IPs that already exist

#### `remove_source_ips.ps1` - Remove IP Aliases

**Usage:**

```powershell
# Run as Administrator
.\remove_source_ips.ps1
```

**Features:**

- **Complete Cleanup**: Removes all IPs in the 192.168.1.2-252 range
- **Cross-Interface Removal**: Finds and removes IPs from any interface
- **Progress Reporting**: Shows which IPs are being removed
- **Safe Operation**: Uses SilentlyContinue to avoid errors on missing IPs

### Linux Bash Scripts

#### `add_source_ips.sh` - Add IP Aliases

**Usage:**

```bash
# Run with sudo
sudo ./add_source_ips.sh
```

**Features:**

- **Automatic Interface Detection**: Uses the default route interface
- **Color-Coded Output**: Green for success, red for errors
- **Efficient Processing**: Adds 251 IP aliases quickly
- **Error Resilience**: Continues processing even if some IPs fail

#### `remove_source_ips.sh` - Remove IP Aliases

**Usage:**

```bash
# Run with sudo
sudo ./remove_source_ips.sh
```

**Features:**

- **Smart Detection**: Finds which interface each IP is on
- **Color-Coded Output**: Yellow for successful removal
- **Complete Cleanup**: Removes all aliases in the range
- **Safe Operation**: Handles missing IPs gracefully

## 🚀 Quick Start Guide

### 1. Setup IP Aliases

**Windows (Run PowerShell as Administrator):**

```powershell
# Simple setup - auto-detects interface
.\add_source_ips.ps1
```

**Linux (Run with sudo):**

```bash
# Simple setup - auto-detects interface
sudo ./add_source_ips.sh
```

### 2. Verify IP Configuration

**Windows:**

```powershell
# Check if IPs were added
Get-NetIPAddress | Where-Object {$_.IPAddress -like "192.168.1.*"}

# Test connectivity
ping -S 192.168.1.2 8.8.8.8
```

**Linux:**

```bash
# Check if IPs were added
ip addr show | grep "192.168.1."

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
```

**Linux:**

```bash
# Remove all IP aliases
sudo ./remove_source_ips.sh
```

## 📈 Test Configuration

### Default Settings

- **Concurrent Users**: 50 simulated users
- **Source IPs**: Up to 251 unique addresses (192.168.1.2-252)
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
# Check if IPs were added successfully
Get-NetIPAddress | Where-Object {$_.IPAddress -like "192.168.1.*"}

# Check network interfaces
Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
```

**Linux:**

```bash
# Check if IPs were added successfully
ip addr show | grep "192.168.1."

# Check network interfaces
ip link show
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

- Verify internet connection: `ping 8.8.8.8`
- Check DNS resolution: `nslookup www.google.com`
- Ensure firewall allows outbound connections
- Test with fewer IPs initially (edit scripts to use smaller range)

### Advanced Troubleshooting

#### Interface Detection Issues

**Windows:**

```powershell
# Show all network interfaces
Get-NetAdapter | Format-Table Name, Status, InterfaceDescription

# If auto-detection fails, edit add_source_ips.ps1 and manually set:
# $interfaceName = "YourInterfaceName"
```

**Linux:**

```bash
# Show all network interfaces
ip link show

# If auto-detection fails, edit add_source_ips.sh and manually set:
# INTERFACE="your_interface_name"
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

- **Up to 250 source IPs** (expanded from 60)
- **Simple, reliable scripts** with automatic interface detection
- **Cross-platform compatibility** improvements
- **Streamlined setup and cleanup** procedures

---

**⚠️ Important Reminders:**

1. Always run IP management scripts as Administrator (Windows) or with sudo (Linux)
2. Remove IP aliases after testing: `.\remove_source_ips.ps1` or `sudo ./remove_source_ips.sh`
3. The 251 IP aliases are temporary and should be cleaned up
4. Test responsibly and only against your own infrastructure
5. Monitor system resources during testing to avoid overload

**🚀 Ready to simulate realistic, multi-source network traffic for comprehensive system testing!**
