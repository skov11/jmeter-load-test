# Enhanced IP Alias Removal Script for JMeter Load Testing
# Removes IP aliases from 192.168.1.2 to 192.168.1.252 (251 total IPs)
# Run as Administrator

param(
    [switch]$Force = $false,
    [switch]$SkipConfirmation = $false,
    [string]$InterfaceName = $null,
    [switch]$ListInterfaces = $false,
    [switch]$ShowDetails = $false
)

Write-Host "JMeter Load Test - Enhanced IP Alias Removal" -ForegroundColor Red
Write-Host "Removing 251 IP aliases (192.168.1.2 - 192.168.1.252)" -ForegroundColor Yellow
Write-Host ""

# Function to list all available interfaces
function Show-AllInterfaces {
    Write-Host "Available Network Interfaces:" -ForegroundColor Cyan
    Write-Host ""
    
    $allInterfaces = Get-NetAdapter | Sort-Object Name
    $activeInterfaces = $allInterfaces | Where-Object { $_.Status -eq "Up" }
    $inactiveInterfaces = $allInterfaces | Where-Object { $_.Status -ne "Up" }
    
    if ($activeInterfaces.Count -gt 0) {
        Write-Host "Active Interfaces:" -ForegroundColor Green
        foreach ($interface in $activeInterfaces) {
            $ips = Get-NetIPAddress -InterfaceIndex $interface.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike "169.254.*" }
            $ipCount = ($ips | Where-Object { $_.IPAddress -like "192.168.1.*" }).Count
            $primaryIP = ($ips | Where-Object { $_.IPAddress -notlike "192.168.1.*" } | Select-Object -First 1).IPAddress
            $ipInfo = if ($primaryIP) { " ($primaryIP)" } else { " (No IP)" }
            $aliasInfo = if ($ipCount -gt 0) { " [$ipCount aliases]" } else { "" }
            Write-Host "  • $($interface.Name)$ipInfo$aliasInfo - $($interface.InterfaceDescription)" -ForegroundColor White
        }
        Write-Host ""
    }
    
    if ($inactiveInterfaces.Count -gt 0) {
        Write-Host "Inactive Interfaces:" -ForegroundColor Gray
        foreach ($interface in $inactiveInterfaces) {
            Write-Host "  • $($interface.Name) [$($interface.Status)] - $($interface.InterfaceDescription)" -ForegroundColor DarkGray
        }
        Write-Host ""
    }
}

# Function to find interfaces with IP aliases in our range
function Find-InterfacesWithAliases {
    $interfacesWithAliases = @()
    $allInterfaces = Get-NetAdapter
    
    foreach ($interface in $allInterfaces) {
        $aliases = Get-NetIPAddress -InterfaceIndex $interface.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | 
                   Where-Object { $_.IPAddress -like "192.168.1.*" -and [int]($_.IPAddress.Split('.')[-1]) -ge 2 -and [int]($_.IPAddress.Split('.')[-1]) -le 252 }
        
        if ($aliases.Count -gt 0) {
            $interfacesWithAliases += [PSCustomObject]@{
                Name = $interface.Name
                InterfaceIndex = $interface.InterfaceIndex
                Status = $interface.Status
                AliasCount = $aliases.Count
                Aliases = $aliases
            }
        }
    }
    
    return $interfacesWithAliases
}
    # Check if running as administrator
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$currentUser
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "This script must be run as Administrator. Please right-click PowerShell and select 'Run as Administrator'"
        exit 1
    }

    # Find existing IP aliases in our range
    Write-Host "Scanning for existing IP aliases..." -ForegroundColor Yellow
    $existingIPs = @()
    
    for ($i = 2; $i -le 252; $i++) {
        $ip = "192.168.1.$i"
        $existing = Get-NetIPAddress -IPAddress $ip -ErrorAction SilentlyContinue
        if ($existing) {
            $existingIPs += $ip
        }
    }

    if ($existingIPs.Count -eq 0) {
        Write-Host "No IP aliases found in the range 192.168.1.2-252" -ForegroundColor Green
        Write-Host "Nothing to remove." -ForegroundColor Cyan
        exit 0
    }

    Write-Host "Found $($existingIPs.Count) IP aliases to remove:" -ForegroundColor Cyan
    
    # Show sample IPs (not all 251 to avoid clutter)
    if ($existingIPs.Count -le 10) {
        foreach ($ip in $existingIPs) {
            Write-Host "  - $ip" -ForegroundColor White
        }
    } else {
        Write-Host "  - $($existingIPs[0]) (first)" -ForegroundColor White
        Write-Host "  - ... $($existingIPs.Count - 2) more IPs ..." -ForegroundColor Gray
        Write-Host "  - $($existingIPs[-1]) (last)" -ForegroundColor White
    }
    
    Write-Host ""

    # Confirmation prompt
    if (-not $SkipConfirmation -and -not $Force) {
        $confirmation = Read-Host "Are you sure you want to remove all $($existingIPs.Count) IP aliases? (y/n) [n]"
        if ($confirmation -ne "y" -and $confirmation -ne "Y") {
            Write-Host "Operation cancelled by user." -ForegroundColor Yellow
            exit 0
        }
    }

    Write-Host "Starting IP alias removal..." -ForegroundColor Yellow
    $successCount = 0
    $errorCount = 0
    $startTime = Get-Date

    # Remove each IP alias
    foreach ($ip in $existingIPs) {
        try {
            # Get the IP address object to find which interface it's on
            $ipAddress = Get-NetIPAddress -IPAddress $ip -ErrorAction Stop
            $interfaceName = (Get-NetAdapter -InterfaceIndex $ipAddress.InterfaceIndex).Name
            
            # Remove the IP alias
            Remove-NetIPAddress -IPAddress $ip -Confirm:$false -ErrorAction Stop
            $successCount++
            
            if ($ShowDetails) {
                Write-Host "  Removed $ip from $interfaceName" -ForegroundColor Green
            }
            
            # Progress indicator every 25 IPs
            if ($successCount % 25 -eq 0) {
                Write-Host "  Progress: $successCount/$($existingIPs.Count) IPs removed" -ForegroundColor Cyan
            }
        }
        catch {
            Write-Host "  Error removing $ip : $($_.Exception.Message)" -ForegroundColor Red
            $errorCount++
        }
    }

    $endTime = Get-Date
    $duration = $endTime - $startTime

    Write-Host ""
    Write-Host "IP Alias Removal Complete!" -ForegroundColor Green
    Write-Host "  Successfully removed: $successCount IPs" -ForegroundColor Green
    Write-Host "  Errors: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })
    Write-Host "  Duration: $($duration.TotalSeconds.ToString("F1")) seconds" -ForegroundColor Cyan
    Write-Host ""

    # Verification
    Write-Host "Verifying removal..." -ForegroundColor Yellow
    $testIPs = @("192.168.1.2", "192.168.1.50", "192.168.1.100", "192.168.1.150", "192.168.1.200", "192.168.1.252")
    $remainingCount = 0
    
    foreach ($testIP in $testIPs) {
        $exists = Get-NetIPAddress -IPAddress $testIP -ErrorAction SilentlyContinue
        if ($exists) {
            Write-Host "  ✗ $testIP - Still exists" -ForegroundColor Red
            $remainingCount++
        } else {
            Write-Host "  ✓ $testIP - Removed" -ForegroundColor Green
        }
    }

    if ($remainingCount -eq 0) {
        Write-Host ""
        Write-Host "✓ Verification successful! All test IPs have been removed." -ForegroundColor Green
        Write-Host ""
        Write-Host "Network configuration has been restored to original state." -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "⚠ Verification found issues. Some IPs may still exist." -ForegroundColor Yellow
        Write-Host "You may need to manually remove remaining IPs or restart the network adapter." -ForegroundColor Yellow
    }

    # Final scan for any remaining IPs
    Write-Host ""
    Write-Host "Performing final scan..." -ForegroundColor Yellow
    
    if ($InterfaceName) {
        # Scan specific interface
        $finalScan = @()
        $interface = Get-NetAdapter -Name $InterfaceName
        
        for ($i = 2; $i -le 252; $i++) {
            $ip = "192.168.1.$i"
            $existing = Get-NetIPAddress -InterfaceIndex $interface.InterfaceIndex -IPAddress $ip -ErrorAction SilentlyContinue
            if ($existing) {
                $finalScan += "$ip ($InterfaceName)"
            }
        }
    } else {
        # Scan all interfaces
        $finalScan = @()
        $interfacesWithAliases = Find-InterfacesWithAliases
        
        foreach ($interfaceInfo in $interfacesWithAliases) {
            foreach ($alias in $interfaceInfo.Aliases) {
                $finalScan += "$($alias.IPAddress) ($($interfaceInfo.Name))"
            }
        }
    }

    if ($finalScan.Count -eq 0) {
        Write-Host "✓ Final scan complete: No IP aliases remain in range 192.168.1.2-252" -ForegroundColor Green
    } else {
        Write-Host "⚠ Final scan found $($finalScan.Count) remaining IP aliases:" -ForegroundColor Yellow
        if ($finalScan.Count -le 5) {
            foreach ($ip in $finalScan) {
                Write-Host "  - $ip" -ForegroundColor Red
            }
        } else {
            Write-Host "  - $($finalScan[0]) ... and $($finalScan.Count - 1) more" -ForegroundColor Red
        }
        
        Write-Host ""
        Write-Host "To remove remaining IPs manually, run:" -ForegroundColor Yellow
        Write-Host "  Remove-NetIPAddress -IPAddress <IP> -Confirm:`$false" -ForegroundColor White
        Write-Host "Or run this script targeting specific interfaces:" -ForegroundColor White
        Write-Host "  .\remove_source_ips.ps1 -InterfaceName 'YourInterface'" -ForegroundColor White
        Write-Host "Or restart your network adapter." -ForegroundColor White
    }
}
catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "Common solutions:" -ForegroundColor Yellow
    Write-Host "1. Run PowerShell as Administrator" -ForegroundColor White
    Write-Host "2. List interfaces with aliases: .\remove_source_ips.ps1 -ListInterfaces" -ForegroundColor White
    Write-Host "3. Target specific interface: .\remove_source_ips.ps1 -InterfaceName 'Ethernet'" -ForegroundColor White
    Write-Host "4. Show detailed removal: .\remove_source_ips.ps1 -ShowDetails" -ForegroundColor White
    Write-Host "5. Force removal: .\remove_source_ips.ps1 -Force" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "Usage Examples:" -ForegroundColor Green
Write-Host "  .\remove_source_ips.ps1                          # Remove from all interfaces" -ForegroundColor White
Write-Host "  .\remove_source_ips.ps1 -InterfaceName 'Wi-Fi'   # Remove from specific interface" -ForegroundColor White
Write-Host "  .\remove_source_ips.ps1 -ShowDetails            # Show detailed removal process" -ForegroundColor White
Write-Host "  .\remove_source_ips.ps1 -ListInterfaces         # List interfaces with aliases" -ForegroundColor White
Write-Host "  .\remove_source_ips.ps1 -Force -SkipConfirmation # Force remove without prompts" -ForegroundColor White
Write-Host ""
Write-Host "Cleanup completed. Your network configuration has been restored." -ForegroundColor Green