# PowerShell script to remove source IPs for JMeter testing
# Run as Administrator
Write-Host "Removing IP addresses from all interfaces..."
# Remove IP addresses from 192.168.1.2 to 192.168.1.252
for ($i = 2; $i -le 252; $i++) {
    $ip = "192.168.1.$i"
    try {
        Remove-NetIPAddress -IPAddress $ip -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "Removed: $ip" -ForegroundColor Yellow
    }
    catch {
        Write-Host "Failed to remove: $ip - $_" -ForegroundColor Red
    }
}
Write-Host "IP address removal complete!"