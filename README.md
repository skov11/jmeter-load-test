# JMeter Traffic Generator Setup Guide for Windows & Ubuntu

## What This Test Plan Accomplishes

### **🎯 Primary Purpose**

This JMeter test plan creates **realistic web browsing traffic** from multiple source IPs to test firewall performance, load balancing, and network security systems under authentic conditions.

### **📊 Traffic Characteristics**

- **50 concurrent users** browsing simultaneously
- **60 unique source IP addresses** (192.168.1.10 through 192.168.1.70)
- **2000+ diverse websites** across multiple categories (social media, e-commerce, news, tech, education, cloud services, etc.)
- **20+ different browser profiles** with realistic headers (User-Agent, screen resolution, DNT settings, etc.)
- **HTTPS and HTTP traffic** with proper SSL/TLS encryption
- **200+ variable search terms** (realistic search queries from everyday items to technical products)
- **Realistic URL paths** and page variations
- **Geographic language diversity** (multiple Accept-Language patterns)
- **Session probability logic** with ThroughputController for realistic user behavior

### **🕒 Realistic Browsing Behavior**

Each simulated user follows **advanced human-like browsing patterns** with **conditional probability logic**:

**Session Probabilities:**

- **80% chance** of visiting category/product pages
- **60% chance** of using search functionality
- **40% chance** of viewing detailed product pages
- **30% chance** of visiting information pages (about, contact, etc.)
- **20% chance** of simulating shopping cart actions (add to cart, view cart)
- **15% chance** of early session abandonment (realistic user dropout)

**Timing Patterns:**

1. **Homepage visit** (15-35 seconds reading time)
2. **Category/product browsing** (33-68 seconds with navigation delays + AJAX requests)
3. **Search functionality** (32-65 seconds including typing simulation with varied search terms)
4. **Detailed page viewing** (51-117 seconds for thorough reading)
5. **Shopping cart simulation** (15-35 seconds cart review for users who add items)
6. **Information page visit** (18-43 seconds quick scan)
7. **Session breaks** (2-7 minutes between complete browsing cycles)

**Mobile vs Desktop Behavior:**

- **Mobile users:** 30% shorter sessions, max 3 pages, faster interactions
- **Desktop users:** Full sessions, max 5 pages, longer reading times
- **Automatic device detection** based on User-Agent strings

### **🔄 Session Details**

- **3 complete browsing cycles** per user with **intelligent probability logic**
- **10-minute gradual ramp-up** (users start at different times)
- **20-35 minutes total test duration** per user
- **Staggered timing** prevents simultaneous requests
- **Cookie and session management** like real browsers
- **Realistic error handling** with retry logic for failed requests
- **AJAX simulation** for dynamic content loading
- **POST requests** for shopping cart and form submissions
- **Enhanced browser headers** including DNT, Sec-Fetch-\*, and Cache-Control

### **🛡️ Firewall Testing Capabilities**

This test plan helps evaluate:

- **Connection handling** under realistic load
- **SSL/TLS inspection** performance with encrypted traffic
- **NAT and connection tracking** with multiple source IPs
- **DNS resolution** performance with diverse domains
- **Content filtering** and web security features
- **Load balancing** effectiveness across multiple users
- **Geographic traffic patterns** with varied User-Agents
- **Session persistence** and state management

### **📈 Expected Traffic Volume**

- **~300-750 total HTTP requests** (varies by user probability paths)
- **~1-4 requests per minute** per user (very conservative, human-like)
- **Peak concurrent connections:** 50-100 (depending on page load times)
- **Data transfer:** Varies by target sites (typically 10-100MB total)
- **Request types:** Mix of GET and POST (Category browsing, Search, AJAX, Shopping cart)
- **Session probabilities:** 80% category, 60% search, 40% product details, 30% info pages, 20% shopping cart actions

### **🔍 What You'll See in Firewall Logs**

- **Diverse source IPs:** Traffic from 192.168.1.10-70
- **Realistic domains:** DNS queries for 2000+ major websites
- **Mixed protocols:** HTTP (port 80) and HTTPS (port 443)
- **Authentic headers:** Proper User-Agent, Accept, Referer headers with DNT and Accept-Encoding
- **Natural timing:** Human-like delays between requests (15-117 seconds)
- **Session behavior:** Cookie exchanges and persistent connections
- **Varied request types:** GET requests for browsing, POST requests for shopping cart actions
- **AJAX traffic:** XMLHttpRequest calls for dynamic content loading
- **Realistic search patterns:** 200+ different search terms across sessions

### **⚠️ Safety Features**

- **Conservative request rates** to avoid detection/blocking
- **Human-like timing** reduces bot detection risk
- **Session probability logic** creates realistic user behavior patterns
- **Configurable targets** (can use test sites instead of real websites)
- **Easy cleanup** of temporary IP aliases after testing
- **Gradual load increase** prevents sudden traffic spikes
- **ThroughputController-based logic** ensures compatibility across JMeter versions

This test plan provides **ultra-realistic, authentic web traffic** with advanced probability-based user behavior simulation, perfect for comprehensive firewall and network security testing. The combination of diverse websites, realistic timing patterns, and sophisticated user journey logic creates traffic that's virtually indistinguishable from real internet users while remaining safe and undetectable by security systems.

## Prerequisites

### Windows Prerequisites

#### 1. Install Java (Required)

1. Download **Java 8 or higher** from [Oracle](https://www.oracle.com/java/technologies/downloads/) or [OpenJDK](https://adoptium.net/)
2. Run the installer and follow the setup wizard
3. Verify installation by opening Command Prompt and typing:
   ```cmd
   java -version
   ```
   You should see Java version information

#### 2. Download JMeter

1. Go to [Apache JMeter Downloads](https://jmeter.apache.org/download_jmeter.cgi)
2. Download the **Binary** zip file (not source) - usually named `apache-jmeter-5.6.3.zip`
3. Extract the zip file to a folder like `C:\jmeter\`

#### 3. Configure Source IP Addresses (Required for Multiple Client Simulation)

**IMPORTANT:** To simulate traffic from multiple client IPs, you must first add IP aliases to your network interface.

##### Find Your Network Interface Name:

1. Open Command Prompt and run:
   ```cmd
   ipconfig
   ```
2. Note the name of your active network connection (e.g., "Ethernet", "Wi-Fi", "Local Area Connection")

##### Add IP Aliases Using PowerShell (Recommended):

1. **Save the PowerShell script** as `add_source_ips.ps1` in your project folder
2. **Open PowerShell as Administrator** (Right-click PowerShell → "Run as Administrator")
3. **Navigate to your project folder:**
   ```powershell
   cd C:\firewall-test
   ```
4. **Run the IP binding script:**
   ```powershell
   .\add_source_ips.ps1
   ```
5. **Verify IPs were added:**
   ```cmd
   ipconfig /all
   ```
   You should see IP addresses 192.168.1.10 through 192.168.1.70 listed

##### Alternative: Add IP Aliases Using Batch File:

1. **Edit the batch file** `add_source_ips.bat` and replace `Ethernet` with your actual interface name
2. **Run Command Prompt as Administrator**
3. **Execute the batch file:**
   ```cmd
   add_source_ips.bat
   ```

##### Test IP Binding:

Verify JMeter can use the new IPs:

```cmd
ping -S 192.168.1.10 8.8.8.8
ping -S 192.168.1.20 8.8.8.8
```

If these commands work, the IP binding is successful.

### Ubuntu Prerequisites

#### 1. Install Java (Required)

1. **Update package list:**
   ```bash
   sudo apt update
   ```
2. **Install OpenJDK:**
   ```bash
   sudo apt install openjdk-11-jdk
   ```
3. **Verify installation:**
   ```bash
   java -version
   ```

#### 2. Download JMeter

1. **Download JMeter:**
   ```bash
   cd /opt
   sudo wget https://downloads.apache.org//jmeter/binaries/apache-jmeter-5.6.3.tgz
   ```
2. **Extract JMeter:**
   ```bash
   sudo tar -xzf apache-jmeter-5.6.3.tgz
   sudo mv apache-jmeter-5.6.3 jmeter
   sudo chown -R $USER:$USER /opt/jmeter
   ```
3. **Add to PATH (optional):**
   ```bash
   echo 'export PATH=$PATH:/opt/jmeter/bin' >> ~/.bashrc
   source ~/.bashrc
   ```

#### 3. Configure Source IP Addresses (Required for Multiple Client Simulation)

##### Find Your Network Interface:

```bash
ip addr show
```

Look for your active interface (usually `eth0`, `ens33`, `enp0s3`, etc.)

##### Add IP Aliases Using Script:

1. **Create the IP binding script** and save as `add_source_ips.sh`
2. **Make it executable:**
   ```bash
   chmod +x add_source_ips.sh
   ```
3. **Run the script:**
   ```bash
   sudo ./add_source_ips.sh
   ```
4. **Verify IPs were added:**
   ```bash
   ip addr show
   ```
   You should see IP addresses 192.168.1.10/24 through 192.168.1.70/24 listed

##### Test IP Binding:

```bash
ping -I 192.168.1.10 -c 2 8.8.8.8
ping -I 192.168.1.20 -c 2 8.8.8.8
```

## Setup Steps

### Step 1: Create Project Directory

1. Create a new folder for your test project:
   ```
   C:\firewall-test\
   ```

### Step 2: Save the Test Files

1. **Save the JMeter Test Plan:**

   - Copy the XML content from the first artifact
   - Save it as `C:\firewall-test\browsing_test.jmx`

2. **Save the User Agents CSV:**

   - Copy the content from the user agents artifact
   - Save it as `C:\firewall-test\user_agents.csv`

3. **Save the Source IPs CSV:**

   - Copy the content from the source IPs artifact
   - Save it as `C:\firewall-test\source_ips.csv`

4. **Save the Websites CSV:**

   - Copy the content from the websites artifact
   - Save it as `C:\firewall-test\websites.csv`

5. **Save the IP Management Scripts:**
   - Copy the PowerShell script content and save as `C:\firewall-test\add_source_ips.ps1`
   - Copy the removal script content and save as `C:\firewall-test\remove_source_ips.ps1`
   - (Optional) Copy the batch file content and save as `C:\firewall-test\add_source_ips.bat`

Your folder structure should look like:

```
C:\firewall-test\
├── browsing_test.jmx
├── user_agents.csv
├── source_ips.csv
├── websites.csv
├── add_source_ips.ps1
├── remove_source_ips.ps1
└── add_source_ips.bat (optional)
```

### Step 3: Configure Your Target (Optional - Now Uses Real Websites)

**The test now automatically visits real websites from the CSV file, but you can still override this:**

1. Open `browsing_test.jmx` in a text editor (Notepad++ recommended)
2. Find these lines near the top:
   ```xml
   <stringProp name="Argument.value">www.example.com</stringProp>
   <stringProp name="Argument.value">80</stringProp>
   <stringProp name="Argument.value">http</stringProp>
   ```
3. Replace with your firewall's details if you want to test a specific target:
   - **TARGET_HOST**: Your firewall IP or hostname (e.g., `192.168.1.1`)
   - **TARGET_PORT**: `80` for HTTP or `443` for HTTPS
   - **PROTOCOL**: `http` or `https`

**Note:** The test now uses the `websites.csv` file by default, so it will visit real websites like Google, YouTube, Amazon, etc.

### Step 4: Start JMeter GUI

1. Open Command Prompt as Administrator
2. Navigate to JMeter bin directory:
   ```cmd
   cd C:\jmeter\apache-jmeter-X.X\bin
   ```
3. Start JMeter GUI:
   ```cmd
   jmeter.bat
   ```

### Step 5: Load the Test Plan

1. In JMeter GUI, click **File → Open**
2. Navigate to `C:\firewall-test\browsing_test.jmx`
3. Click **Open**

### Step 6: Verify CSV Files Are Found

1. In the Test Plan tree, click on **"User Agent Data"**
2. Check that the **Filename** field shows: `user_agents.csv`
3. Click on **"Source IP Data"**
4. Check that the **Filename** field shows: `source_ips.csv`
5. Click on **"Website Data"**
6. Check that the **Filename** field shows: `websites.csv`

_Note: JMeter looks for CSV files relative to the .jmx file location_

### Step 7: Configure Test Parameters (Optional)

1. Click on **"Browsing Users"** thread group
2. Adjust settings if needed:
   - **Number of Threads**: 50 (number of simulated users)
   - **Ramp-up Period**: 600 seconds (10 minutes to start all users)
   - **Loop Count**: 3 (how many times each user repeats the browsing flow)

### Step 8: Run the Test

**IMPORTANT:** Make sure you have added the IP aliases (Step 3) before running the test, otherwise JMeter cannot bind to the source IPs.

#### Option A: GUI Mode (for testing/debugging)

1. Click the green **Start** button (triangle icon)
2. Watch the test progress in real-time
3. View results in **"Summary Report"**
4. **Check your firewall logs** - you should now see traffic from multiple source IPs (192.168.1.10-70)

#### Option B: Command Line Mode (for actual load testing)

1. Close JMeter GUI
2. Open Command Prompt in your test folder:
   ```cmd
   cd C:\firewall-test
   ```
3. Run the test:
   ```cmd
   C:\jmeter\apache-jmeter-X.X\bin\jmeter.bat -n -t browsing_test.jmx -l results.jtl
   ```

## Post-Test Cleanup

### Windows Cleanup

**Remove IP Aliases (IMPORTANT)** - After completing your firewall testing, remove the temporary IP addresses:

1. **Open PowerShell as Administrator**
2. **Navigate to your project folder:**
   ```powershell
   cd C:\firewall-test
   ```
3. **Run the removal script:**
   ```powershell
   .\remove_source_ips.ps1
   ```
4. **Verify removal:**
   ```cmd
   ipconfig /all
   ```
   The 192.168.1.10-70 addresses should no longer be listed

### Ubuntu Cleanup

**Remove IP Aliases (IMPORTANT)** - After completing your firewall testing, remove the temporary IP addresses:

1. **Navigate to your project folder:**
   ```bash
   cd ~/firewall-test
   ```
2. **Run the removal script:**
   ```bash
   sudo ./remove_source_ips.sh
   ```
3. **Verify removal:**
   ```bash
   ip addr show
   ```
   The 192.168.1.10/24-70/24 addresses should no longer be listed

## Monitoring Your Test

### During the Test

- **GUI Mode**: Watch the Summary Report for real-time statistics
- **Command Line**: Monitor the console output for progress
- **Firewall**: Check your firewall logs for incoming connections

### After the Test

1. **View Results** (if using command line):

   ```cmd
   C:\jmeter\apache-jmeter-5.6.3\bin\jmeter.bat -g results.jtl -o report
   ```

   This creates an HTML report in the `report` folder

2. **Key Metrics to Check:**
   - Response times
   - Error rates
   - Throughput (requests/second)
   - Firewall performance and logs

## Troubleshooting

### Windows Issues

**"Cannot bind to source IP" or "Address already in use":**

- Verify IP aliases were added successfully using `ipconfig /all`
- Check that the IP range doesn't conflict with existing network devices
- Try using a different IP range in both the CSV file and the scripts

**"CSV file not found" error:**

- Ensure CSV files are in the same folder as the .jmx file
- Check file names match exactly (case-sensitive)

**Java not found:**

- Verify Java is installed and in your PATH
- Try running: `java -version` in Command Prompt

**Permission errors:**

- Run Command Prompt/PowerShell as Administrator
- Check Windows firewall isn't blocking JMeter

**No traffic showing in firewall logs:**

- Verify IP aliases are properly configured (`ipconfig /all` or `ip addr show`)
- Check that your default gateway points to the firewall
- Test binding with: `ping -S 192.168.1.10 8.8.8.8` (Windows) or `ping -I 192.168.1.10 -c 2 8.8.8.8` (Ubuntu)
- Monitor firewall interfaces during the test
- Ensure all required CSV files are present and properly formatted
- Check that websites.csv contains valid domains (2000+ entries)

**High CPU usage:**

- Reduce number of threads for initial testing
- Use command line mode instead of GUI for actual load testing

### Ubuntu Issues

**"Cannot bind to source IP" or "Cannot assign requested address":**

- Verify IP aliases were added successfully using `ip addr show`
- Check that the IP range doesn't conflict with existing network devices
- Ensure you ran the script with sudo: `sudo ./add_source_ips.sh`

**"Permission denied" when running scripts:**

- Make scripts executable: `chmod +x add_source_ips.sh remove_source_ips.sh`
- Run IP scripts with sudo: `sudo ./add_source_ips.sh`

**Java not found:**

- Install OpenJDK: `sudo apt install openjdk-11-jdk`
- Verify installation: `java -version`

**JMeter command not found:**

- Use full path: `/opt/jmeter/bin/jmeter`
- Or add to PATH: `export PATH=$PATH:/opt/jmeter/bin`

**No traffic showing in firewall logs:**

- Verify IP aliases: `ip addr show`
- Test binding: `ping -I 192.168.1.10 -c 2 8.8.8.8`
- Check default route: `ip route show default`
- Monitor network interface: `sudo tcpdump -i eth0 host 192.168.1.10`

**Display issues (headless systems):**

- Use command line mode only: `jmeter -n -t browsing_test.jmx -l results.jtl`
- Install X11 forwarding if GUI needed: `sudo apt install xauth`

### Common Cross-Platform Issues

**DNS Resolution Issues:**

- Test with: `nslookup www.google.com`
- Check /etc/resolv.conf (Ubuntu) or DNS settings (Windows)

**Network Connectivity:**

- Verify internet connection
- Check firewall rules on test machine
- Test basic connectivity: `ping 8.8.8.8`

**JMeter Performance:**

- Increase JVM heap size: `export JVM_ARGS="-Xms1g -Xmx4g"`
- Use non-GUI mode for production testing
- Monitor system resources during test Verify IP aliases are properly configured (`ipconfig /all`)
- Check that your default gateway points to the firewall
- Test binding with: `ping -S 192.168.1.10 8.8.8.8`
- Monitor firewall interfaces during the test

**High CPU usage:**

- Reduce number of threads for initial testing
- Use command line mode instead of GUI for actual load testing

### Network Configuration

If you need to configure network interfaces for the source IPs:

1. Open Command Prompt as Administrator
2. Add IP aliases (example):
   ```cmd
   netsh interface ip add address "Local Area Connection" 192.168.1.10 255.255.255.0
   netsh interface ip add address "Local Area Connection" 192.168.1.11 255.255.255.0
   ```

## Performance Tips

1. **Use Command Line** for serious load testing (GUI adds overhead)
2. **Increase Java heap** for high load:
   ```cmd
   set HEAP="-Xms1g -Xmx4g"
   jmeter.bat -n -t browsing_test.jmx -l results.jtl
   ```
3. **Monitor system resources** during testing
4. **Start small** - test with 10 users first, then scale up

## Safety Reminders

- Only test against your own firewall or with explicit permission
- Use isolated test networks when possible
- **Always remove IP aliases after testing** to avoid network conflicts
- Monitor system resources to avoid overloading your test machine
- Have a plan to stop the test quickly if needed
- **Remember:** The IP aliases (192.168.1.10-70) are temporary and should be removed when testing is complete

Your traffic generator is now ready to simulate realistic browsing behavior from 50+ different client IPs!
