# JMeter Traffic Generator Setup Guide for Windows

## Prerequisites

### 1. Install Java (Required)
1. Download **Java 8 or higher** from [Oracle](https://www.oracle.com/java/technologies/downloads/) or [OpenJDK](https://adoptium.net/)
2. Run the installer and follow the setup wizard
3. Verify installation by opening Command Prompt and typing:
   ```cmd
   java -version
   ```
   You should see Java version information

### 2. Download JMeter
1. Go to [Apache JMeter Downloads](https://jmeter.apache.org/download_jmeter.cgi)
2. Download the **Binary** zip file (not source) - usually named `apache-jmeter-X.X.zip`
3. Extract the zip file to a folder like `C:\jmeter\`

### 3. Configure Source IP Addresses (Required for Multiple Client Simulation)
**IMPORTANT:** To simulate traffic from multiple client IPs, you must first add IP aliases to your network interface.

#### Find Your Network Interface Name:
1. Open Command Prompt and run:
   ```cmd
   ipconfig
   ```
2. Note the name of your active network connection (e.g., "Ethernet", "Wi-Fi", "Local Area Connection")

#### Add IP Aliases Using PowerShell (Recommended):
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

#### Alternative: Add IP Aliases Using Batch File:
1. **Edit the batch file** `add_source_ips.bat` and replace `Ethernet` with your actual interface name
2. **Run Command Prompt as Administrator**
3. **Execute the batch file:**
   ```cmd
   add_source_ips.bat
   ```

#### Test IP Binding:
Verify JMeter can use the new IPs:
```cmd
ping -S 192.168.1.10 8.8.8.8
ping -S 192.168.1.20 8.8.8.8
```
If these commands work, the IP binding is successful.

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

*Note: JMeter looks for CSV files relative to the .jmx file location*

### Step 7: Configure Test Parameters (Optional)
1. Click on **"Browsing Users"** thread group
2. Adjust settings if needed:
   - **Number of Threads**: 50 (number of simulated users)
   - **Ramp-up Period**: 60 seconds (time to start all users)
   - **Loop Count**: 10 (how many times each user repeats the browsing flow)

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

### Remove IP Aliases (IMPORTANT)
After completing your firewall testing, remove the temporary IP addresses:

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

## Monitoring Your Test

### During the Test
- **GUI Mode**: Watch the Summary Report for real-time statistics
- **Command Line**: Monitor the console output for progress
- **Firewall**: Check your firewall logs for incoming connections

### After the Test
1. **View Results** (if using command line):
   ```cmd
   C:\jmeter\apache-jmeter-X.X\bin\jmeter.bat -g results.jtl -o report
   ```
   This creates an HTML report in the `report` folder

2. **Key Metrics to Check:**
   - Response times
   - Error rates
   - Throughput (requests/second)
   - Firewall performance and logs

## Troubleshooting

### Common Issues

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
- Verify IP aliases are properly configured (`ipconfig /all`)
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
