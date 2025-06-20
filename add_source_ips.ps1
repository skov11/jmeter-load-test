# Enhanced IP Alias Setup Script for JMeter Load Testing
# Adds IP aliases from 192.168.1.2 to 192.168.1.252 (251 total IPs)
# Run as Administrator

param(
    [string]$InterfaceName = $null,
    [switch]$AutoDetect = $false,
    [switch]$ListInterfaces = $false,
    [switch]$Interactive = $false
)

Write-Host "JMeter Load Test - Enhanced IP Alias Setup" -ForegroundColor Green
Write-Host "Adding 251 IP aliases (192.168.1.2 - 192.168.1.252)" -ForegroundColor Yellow
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
            $ip = (Get-NetIPAddress -InterfaceIndex $interface.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike "169.254.*" } | Select-Object -First 1).IPAddress
            $ipInfo = if ($ip) { " ($ip)" } else { " (No IP)" }
            Write-Host "  • $($interface.Name)$ipInfo - $($interface.InterfaceDescription)" -ForegroundColor White
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

# Function to get interface selection from user
function Get-InterfaceSelection {
    param([bool]$showInactive = $false)
    
    $interfaces = if ($showInactive) {
        Get-NetAdapter | Sort-Object Name
    } else {
        Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.InterfaceType -ne "Software Loopback" } | Sort-Object Name
    }
    
    if ($interfaces.Count -eq 0) {
        throw "No suitable network interfaces found"
    }
    
    Write-Host "Select Network Interface:" -ForegroundColor Yellow
    Write-Host ""
    
    for ($i = 0; $i -lt $interfaces.Count; $i++) {
        $interface = $interfaces[$i]
        $ip = (Get-NetIPAddress -InterfaceIndex $interface.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike "169.254.*" } | Select-Object -First 1).IPAddress
        $ipInfo = if ($ip) { " ($ip)" } else { " (No IP)" }
        $statusColor = if ($interface.Status -eq "Up") { "Green" } else { "Yellow" }
        $statusText = "[$($interface.Status)]"
        
        Write-Host "  [$i] " -NoNewline -ForegroundColor Cyan
        Write-Host "$($interface.Name)" -NoNewline -ForegroundColor White
        Write-Host "$ipInfo " -NoNewline -ForegroundColor Gray
        Write-Host "$statusText" -ForegroundColor $statusColor
        Write-Host "      $($interface.InterfaceDescription)" -ForegroundColor DarkGray
    }
    
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  [a] Show all interfaces (including inactive)" -ForegroundColor Gray
    Write-Host "  [r] Refresh interface list" -ForegroundColor Gray
    Write-Host "  [q] Quit" -ForegroundColor Gray
    Write-Host ""
    
    do {
        $selection = Read-Host "Select interface number, or option (0-$($interfaces.Count-1), a, r, q)"
        
        switch ($selection.ToLower()) {
            "a" {
                if (-not $showInactive) {
                    return Get-InterfaceSelection -showInactive $true
                } else {
                    Write-Host "Already showing all interfaces" -ForegroundColor Yellow
                    continue
                }
            }
            "r" {
                Write-Host "Refreshing interface list..." -ForegroundColor Yellow
                return Get-InterfaceSelection -showInactive $showInactive
            }
            "q" {
                Write-Host "Exiting..." -ForegroundColor Yellow
                exit 0
            }
            default {
                if ($selection -match '^\d+

try {
    # Check if running as administrator
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$currentUser
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "This script must be run as Administrator. Please right-click PowerShell and select 'Run as Administrator'"
        exit 1
    }

    # Handle list interfaces option
    if ($ListInterfaces) {
        Show-AllInterfaces
        exit 0
    }

    # Determine interface name
    if ($Interactive -or (-not $InterfaceName -and -not $AutoDetect)) {
        Write-Host "Interactive mode: Please select a network interface" -ForegroundColor Cyan
        $InterfaceName = Get-InterfaceSelection
    }
    elseif (-not $InterfaceName) {
        Write-Host "Auto-detecting network interface..." -ForegroundColor Yellow
        $InterfaceName = Get-ActiveInterface
    }
    
    Write-Host "Using network interface: $InterfaceName" -ForegroundColor Green
    Write-Host ""

    # Verify interface exists and show details
    $interface = Get-NetAdapter -Name $InterfaceName -ErrorAction SilentlyContinue
    if (-not $interface) {
        Write-Error "Network interface '$InterfaceName' not found"
        Write-Host ""
        Write-Host "Available interfaces:" -ForegroundColor Yellow
        Show-AllInterfaces
        exit 1
    }

    # Show interface details
    $currentIP = (Get-NetIPAddress -InterfaceIndex $interface.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike "169.254.*" } | Select-Object -First 1).IPAddress
    Write-Host "Interface Details:" -ForegroundColor Cyan
    Write-Host "  Name: $($interface.Name)" -ForegroundColor White
    Write-Host "  Description: $($interface.InterfaceDescription)" -ForegroundColor Gray
    Write-Host "  Status: $($interface.Status)" -ForegroundColor $(if ($interface.Status -eq "Up") { "Green" } else { "Yellow" })
    Write-Host "  Current IP: $(if ($currentIP) { $currentIP } else { "None" })" -ForegroundColor Gray
    Write-Host ""

    # Warn if interface is not up
    if ($interface.Status -ne "Up") {
        Write-Host "⚠ Warning: Interface '$InterfaceName' is not active (Status: $($interface.Status))" -ForegroundColor Yellow
        $continue = Read-Host "Continue anyway? (y/N)"
        if ($continue -ne "y" -and $continue -ne "Y") {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
            exit 0
        }
    }

    Write-Host "Starting IP alias addition..." -ForegroundColor Yellow
    $successCount = 0
    $errorCount = 0
    $startTime = Get-Date

    # Add IP aliases from 192.168.1.2 to 192.168.1.252
    for ($i = 2; $i -le 252; $i++) {
        $ip = "192.168.1.$i"
        try {
            # Check if IP already exists
            $existing = Get-NetIPAddress -IPAddress $ip -ErrorAction SilentlyContinue
            if ($existing) {
                Write-Host "  $ip - Already exists" -ForegroundColor Yellow
                continue
            }

            # Add the IP alias
            New-NetIPAddress -InterfaceAlias $InterfaceName -IPAddress $ip -PrefixLength 24 -ErrorAction Stop | Out-Null
            $successCount++
            
            # Progress indicator every 25 IPs
            if ($i % 25 -eq 0) {
                Write-Host "  Progress: $i/251 IPs processed ($successCount added)" -ForegroundColor Cyan
            }
        }
        catch {
            Write-Host "  Error adding $ip : $($_.Exception.Message)" -ForegroundColor Red
            $errorCount++
        }
    }

    $endTime = Get-Date
    $duration = $endTime - $startTime

    Write-Host ""
    Write-Host "IP Alias Setup Complete!" -ForegroundColor Green
    Write-Host "  Successfully added: $successCount IPs" -ForegroundColor Green
    Write-Host "  Errors: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })
    Write-Host "  Duration: $($duration.TotalSeconds.ToString("F1")) seconds" -ForegroundColor Cyan
    Write-Host ""

    # Verification
    Write-Host "Verifying setup..." -ForegroundColor Yellow
    $testIPs = @("192.168.1.2", "192.168.1.50", "192.168.1.100", "192.168.1.150", "192.168.1.200", "192.168.1.252")
    $verifyCount = 0
    
    foreach ($testIP in $testIPs) {
        $exists = Get-NetIPAddress -IPAddress $testIP -ErrorAction SilentlyContinue
        if ($exists) {
            $verifyCount++
            Write-Host "  ✓ $testIP - OK" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $testIP - Missing" -ForegroundColor Red
        }
    }

    if ($verifyCount -eq $testIPs.Count) {
        Write-Host ""
        Write-Host "✓ Verification successful! All test IPs are configured." -ForegroundColor Green
        Write-Host ""
        Write-Host "You can now run your JMeter test with 251 unique source IPs." -ForegroundColor Cyan
        Write-Host "Remember to run remove_source_ips.ps1 after testing to clean up." -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "⚠ Verification found issues. Some IPs may not be properly configured." -ForegroundColor Yellow
    }

    # Test connectivity (optional)
    Write-Host ""
    $testConnectivity = Read-Host "Test connectivity with sample IPs? (y/n) [n]"
    if ($testConnectivity -eq "y" -or $testConnectivity -eq "Y") {
        Write-Host "Testing connectivity..." -ForegroundColor Yellow
        $testResults = @()
        
        foreach ($testIP in @("192.168.1.2", "192.168.1.100", "192.168.1.252")) {
            try {
                $result = Test-NetConnection -ComputerName "8.8.8.8" -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue
                if ($result) {
                    Write-Host "  ✓ $testIP - Connectivity OK" -ForegroundColor Green
                    $testResults += $true
                } else {
                    Write-Host "  ✗ $testIP - Connectivity failed" -ForegroundColor Red
                    $testResults += $false
                }
            }
            catch {
                Write-Host "  ✗ $testIP - Test failed: $($_.Exception.Message)" -ForegroundColor Red
                $testResults += $false
            }
        }
        
        if ($testResults -contains $true) {
            Write-Host "  Network connectivity verified!" -ForegroundColor Green
        } else {
            Write-Host "  Warning: Connectivity tests failed. Check network configuration." -ForegroundColor Yellow
        }
    }
}
catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "Common solutions:" -ForegroundColor Yellow
    Write-Host "1. Run PowerShell as Administrator" -ForegroundColor White
    Write-Host "2. Check available interfaces: .\add_source_ips.ps1 -ListInterfaces" -ForegroundColor White
    Write-Host "3. Use interactive mode: .\add_source_ips.ps1 -Interactive" -ForegroundColor White
    Write-Host "4. Specify interface manually: .\add_source_ips.ps1 -InterfaceName 'Ethernet'" -ForegroundColor White
    Write-Host "5. Ensure Windows firewall allows the operation" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "Usage Examples:" -ForegroundColor Green
Write-Host "  .\add_source_ips.ps1                          # Auto-detect interface" -ForegroundColor White
Write-Host "  .\add_source_ips.ps1 -Interactive             # Interactive interface selection" -ForegroundColor White
Write-Host "  .\add_source_ips.ps1 -InterfaceName 'Wi-Fi'   # Specify interface directly" -ForegroundColor White
Write-Host "  .\add_source_ips.ps1 -ListInterfaces          # List all available interfaces" -ForegroundColor White
Write-Host ""
Write-Host "Script completed. You can now use JMeter with enhanced multi-IP testing capabilities." -ForegroundColor Green) {
                    $selectedIndex = [int]$selection
                    if ($selectedIndex -ge 0 -and $selectedIndex -lt $interfaces.Count) {
                        return $interfaces[$selectedIndex].Name
                    }
                }
                Write-Host "Invalid selection. Please try again." -ForegroundColor Red
            }
        }
    } while ($true)
}

# Function to get active network interface (auto-detect)
function Get-ActiveInterface {
    $interfaces = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.InterfaceType -ne "Software Loopback" }
    
    if ($interfaces.Count -eq 1) {
        return $interfaces[0].Name
    }
    elseif ($interfaces.Count -gt 1) {
        Write-Host "Multiple active interfaces found. Auto-selecting the first one with an IP address..." -ForegroundColor Yellow
        
        foreach ($interface in $interfaces) {
            $ip = (Get-NetIPAddress -InterfaceIndex $interface.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike "169.254.*" } | Select-Object -First 1).IPAddress
            if ($ip) {
                Write-Host "Selected: $($interface.Name) ($ip)" -ForegroundColor Green
                return $interface.Name
            }
        }
        
        # If no interface has an IP, just return the first one
        Write-Host "No interface with IP found, selecting: $($interfaces[0].Name)" -ForegroundColor Yellow
        return $interfaces[0].Name
    }
    else {
        throw "No active network interfaces found"
    }
}

try {
    # Check if running as administrator
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$currentUser
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "This script must be run as Administrator. Please right-click PowerShell and select 'Run as Administrator'"
        exit 1
    }

    # Determine interface name
    if (-not $InterfaceName) {
        $InterfaceName = Get-ActiveInterface
    }
    
    Write-Host "Using network interface: $InterfaceName" -ForegroundColor Green
    Write-Host ""

    # Verify interface exists
    $interface = Get-NetAdapter -Name $InterfaceName -ErrorAction SilentlyContinue
    if (-not $interface) {
        Write-Error "Network interface '$InterfaceName' not found"
        Write-Host "Available interfaces:" -ForegroundColor Yellow
        Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Format-Table Name, InterfaceDescription, Status
        exit 1
    }

    Write-Host "Starting IP alias addition..." -ForegroundColor Yellow
    $successCount = 0
    $errorCount = 0
    $startTime = Get-Date

    # Add IP aliases from 192.168.1.2 to 192.168.1.252
    for ($i = 2; $i -le 252; $i++) {
        $ip = "192.168.1.$i"
        try {
            # Check if IP already exists
            $existing = Get-NetIPAddress -IPAddress $ip -ErrorAction SilentlyContinue
            if ($existing) {
                Write-Host "  $ip - Already exists" -ForegroundColor Yellow
                continue
            }

            # Add the IP alias
            New-NetIPAddress -InterfaceAlias $InterfaceName -IPAddress $ip -PrefixLength 24 -ErrorAction Stop | Out-Null
            $successCount++
            
            # Progress indicator every 25 IPs
            if ($i % 25 -eq 0) {
                Write-Host "  Progress: $i/251 IPs processed ($successCount added)" -ForegroundColor Cyan
            }
        }
        catch {
            Write-Host "  Error adding $ip : $($_.Exception.Message)" -ForegroundColor Red
            $errorCount++
        }
    }

    $endTime = Get-Date
    $duration = $endTime - $startTime

    Write-Host ""
    Write-Host "IP Alias Setup Complete!" -ForegroundColor Green
    Write-Host "  Successfully added: $successCount IPs" -ForegroundColor Green
    Write-Host "  Errors: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })
    Write-Host "  Duration: $($duration.TotalSeconds.ToString("F1")) seconds" -ForegroundColor Cyan
    Write-Host ""

    # Verification
    Write-Host "Verifying setup..." -ForegroundColor Yellow
    $testIPs = @("192.168.1.2", "192.168.1.50", "192.168.1.100", "192.168.1.150", "192.168.1.200", "192.168.1.252")
    $verifyCount = 0
    
    foreach ($testIP in $testIPs) {
        $exists = Get-NetIPAddress -IPAddress $testIP -ErrorAction SilentlyContinue
        if ($exists) {
            $verifyCount++
            Write-Host "  ✓ $testIP - OK" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $testIP - Missing" -ForegroundColor Red
        }
    }

    if ($verifyCount -eq $testIPs.Count) {
        Write-Host ""
        Write-Host "✓ Verification successful! All test IPs are configured." -ForegroundColor Green
        Write-Host ""
        Write-Host "You can now run your JMeter test with 251 unique source IPs." -ForegroundColor Cyan
        Write-Host "Remember to run remove_source_ips.ps1 after testing to clean up." -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "⚠ Verification found issues. Some IPs may not be properly configured." -ForegroundColor Yellow
    }

    # Test connectivity (optional)
    Write-Host ""
    $testConnectivity = Read-Host "Test connectivity with sample IPs? (y/n) [n]"
    if ($testConnectivity -eq "y" -or $testConnectivity -eq "Y") {
        Write-Host "Testing connectivity..." -ForegroundColor Yellow
        $testResults = @()
        
        foreach ($testIP in @("192.168.1.2", "192.168.1.100", "192.168.1.252")) {
            try {
                $result = Test-NetConnection -ComputerName "8.8.8.8" -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue
                if ($result) {
                    Write-Host "  ✓ $testIP - Connectivity OK" -ForegroundColor Green
                    $testResults += $true
                } else {
                    Write-Host "  ✗ $testIP - Connectivity failed" -ForegroundColor Red
                    $testResults += $false
                }
            }
            catch {
                Write-Host "  ✗ $testIP - Test failed: $($_.Exception.Message)" -ForegroundColor Red
                $testResults += $false
            }
        }
        
        if ($testResults -contains $true) {
            Write-Host "  Network connectivity verified!" -ForegroundColor Green
        } else {
            Write-Host "  Warning: Connectivity tests failed. Check network configuration." -ForegroundColor Yellow
        }
    }
}
catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "Common solutions:" -ForegroundColor Yellow
    Write-Host "1. Run PowerShell as Administrator" -ForegroundColor White
    Write-Host "2. Check network interface name: Get-NetAdapter" -ForegroundColor White
    Write-Host "3. Ensure Windows firewall allows the operation" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "Script completed. You can now use JMeter with enhanced multi-IP testing capabilities." -ForegroundColor Green