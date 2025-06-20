# PowerShell script to add source IPs for JMeter testing
# Run as Administrator

# Get the active network interface (modify if needed)
$interfaceName = (Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.InterfaceDescription -notlike "*Loopback*"} | Select-Object -First 1).Name

Write-Host "Adding IP addresses to interface: $interfaceName"

# Add IP addresses from 192.168.1.10 to 192.168.1.70
for ($i = 10; $i -le 70; $i++) {
    $ip = "192.168.1.$i"
    try {
        New-NetIPAddress -InterfaceAlias $interfaceName -IPAddress $ip -PrefixLength 24 -ErrorAction SilentlyContinue
        Write-Host "Added: $ip" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to add: $ip - $_" -ForegroundColor Red
    }
}

Write-Host "IP address binding complete!"
Write-Host "To remove these IPs later, run: remove_source_ips.ps1"
