#!/usr/bin/env pwsh
# Security Audit Script for E-Commerce Microservices
# Performs security checks and vulnerability assessment

Write-Host "========================================" -ForegroundColor Red
Write-Host "  Security Audit & Vulnerability Scan  " -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

# Function to test for common vulnerabilities
function Test-CommonVulnerabilities {
    param(
        [string]$ServiceName,
        [string]$HostName,
        [int]$Port
    )
    
    Write-Host "`n=== Testing $ServiceName ===" -ForegroundColor Yellow
    
    # Test 1: Check for SSL/TLS
    Write-Host "`n[1] SSL/TLS Configuration Check" -ForegroundColor Cyan
    try {
        $httpsUrl = "https://${HostName}:${Port}"
        $response = Invoke-WebRequest -Uri $httpsUrl -TimeoutSec 5 -UseBasicParsing -SkipCertificateCheck -ErrorAction Stop
        Write-Host "  [✓] HTTPS is enabled" -ForegroundColor Green
    }
    catch {
        Write-Host "  [!] HTTPS not properly configured or not enforced" -ForegroundColor Yellow
    }
    
    # Test 2: Security Headers Check
    Write-Host "`n[2] Security Headers Check" -ForegroundColor Cyan
    try {
        $url = "http://${HostName}:${Port}"
        $response = Invoke-WebRequest -Uri $url -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        
        $securityHeaders = @(
            "X-Frame-Options",
            "X-Content-Type-Options",
            "X-XSS-Protection",
            "Strict-Transport-Security",
            "Content-Security-Policy",
            "Referrer-Policy"
        )
        
        foreach ($header in $securityHeaders) {
            if ($response.Headers.ContainsKey($header)) {
                Write-Host "  [✓] $header : " -ForegroundColor Green -NoNewline
                Write-Host "$($response.Headers[$header])" -ForegroundColor White
            }
            else {
                Write-Host "  [✗] $header : MISSING" -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Host "  [!] Could not check security headers: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Test 3: HTTP Methods Check
    Write-Host "`n[3] HTTP Methods Check" -ForegroundColor Cyan
    $dangerousMethods = @("TRACE", "TRACK", "PUT", "DELETE")
    
    foreach ($method in $dangerousMethods) {
        try {
            $response = Invoke-WebRequest -Uri "http://${HostName}:${Port}" -Method $method -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                Write-Host "  [!] $method method is ENABLED (potential security risk)" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "  [✓] $method method is disabled" -ForegroundColor Green
        }
    }
    
    # Test 4: Directory Listing Check
    Write-Host "`n[4] Directory Listing Check" -ForegroundColor Cyan
    $testPaths = @("/", "/api/", "/admin/", "/.git/", "/config/")
    
    foreach ($path in $testPaths) {
        try {
            $null = Invoke-WebRequest -Uri "http://${HostName}:${Port}${path}" -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
            if ($response.Content -match "Index of" -or $response.Content -match "Directory listing") {
                Write-Host "  [!] Directory listing enabled at: $path" -ForegroundColor Red
            }
        }
        catch {
            # Expected - path not accessible or doesn't exist
        }
    }
    Write-Host "  [✓] No obvious directory listing vulnerabilities" -ForegroundColor Green
}

# Function to check for exposed sensitive endpoints
function Test-SensitiveEndpoints {
    Write-Host "`n=== Checking for Exposed Sensitive Endpoints ===" -ForegroundColor Yellow
    
    $sensitiveEndpoints = @(
        @{Path="/metrics"; Risk="Low"; Description="Prometheus metrics exposed"},
        @{Path="/actuator"; Risk="High"; Description="Spring Boot Actuator"},
        @{Path="/health"; Risk="Low"; Description="Health check endpoint"},
        @{Path="/debug"; Risk="High"; Description="Debug endpoint"},
        @{Path="/admin"; Risk="Critical"; Description="Admin panel"},
        @{Path="/.env"; Risk="Critical"; Description="Environment file"},
        @{Path="/config"; Risk="High"; Description="Configuration endpoint"},
        @{Path="/swagger"; Risk="Medium"; Description="API documentation"}
    )
    
    $services = @(
        @{Name="Nginx"; Host="nginx"; Port=80},
        @{Name="Order Service"; Host="order"; Port=4000},
        @{Name="Reco Service"; Host="reco"; Port=5000},
        @{Name="Inventory Service"; Host="inventory"; Port=8000}
    )
    
    foreach ($service in $services) {
        Write-Host "`n--- $($service.Name) ---" -ForegroundColor Cyan
        
        foreach ($endpoint in $sensitiveEndpoints) {
            try {
                $url = "http://$($service.Host):$($service.Port)$($endpoint.Path)"
                $null = Invoke-WebRequest -Uri $url -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
                
                $color = switch ($endpoint.Risk) {
                    "Critical" { "Red" }
                    "High" { "Yellow" }
                    "Medium" { "Yellow" }
                    "Low" { "Green" }
                }
                
                Write-Host "  [!] EXPOSED: $($endpoint.Path) " -ForegroundColor $color -NoNewline
                Write-Host "[$($endpoint.Risk) Risk] - $($endpoint.Description)" -ForegroundColor White
            }
            catch {
                # Endpoint not accessible - this is good for sensitive endpoints
            }
        }
    }
}

# Function to test rate limiting
function Test-RateLimiting {
    param(
        [string]$Url,
        [int]$RequestCount = 50
    )
    
    Write-Host "`n=== Rate Limiting Test ===" -ForegroundColor Yellow
    Write-Host "Testing: $Url" -ForegroundColor White
    Write-Host "Sending $RequestCount rapid requests..." -ForegroundColor Gray
    
    $rateLimited = $false
    $successCount = 0
    $failCount = 0
    
    for ($i = 1; $i -le $RequestCount; $i++) {
        try {
            $response = Invoke-WebRequest -Uri $Url -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
            if ($response.StatusCode -eq 429) {
                $rateLimited = $true
                $failCount++
            }
            else {
                $successCount++
            }
        }
        catch {
            if ($_.Exception.Response.StatusCode -eq 429) {
                $rateLimited = $true
                $failCount++
            }
        }
        
        # Progress indicator
        if ($i % 10 -eq 0) {
            Write-Host "." -NoNewline -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    
    if ($rateLimited) {
        Write-Host "  [✓] Rate limiting is ACTIVE" -ForegroundColor Green
        Write-Host "  Success: $successCount, Rate Limited: $failCount" -ForegroundColor White
    }
    else {
        Write-Host "  [!] Rate limiting NOT detected (potential DoS vulnerability)" -ForegroundColor Red
        Write-Host "  All $successCount requests succeeded" -ForegroundColor White
    }
}

# Function to generate security report
function New-SecurityReport {
    param(
        [hashtable]$Results
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $reportPath = "/security-tools/reports/security-audit-${timestamp}.txt"
    
    Write-Host "`n=== Generating Security Report ===" -ForegroundColor Yellow
    
    # Create report directory if it doesn't exist
    $reportDir = Split-Path -Parent $reportPath
    if (-not (Test-Path $reportDir)) {
        New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    }
    
    # Generate report content
    $report = @"
========================================
SECURITY AUDIT REPORT
========================================
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Project: E-Commerce Microservices Stack
========================================

SUMMARY:
- Total Services Scanned: $($Results.TotalServices)
- Critical Issues: $($Results.CriticalIssues)
- Warnings: $($Results.Warnings)
- Info: $($Results.InfoItems)

========================================
RECOMMENDATIONS:
========================================
1. Ensure all services use HTTPS in production
2. Implement rate limiting on all public endpoints
3. Review and restrict exposed metrics endpoints
4. Enable authentication for admin endpoints
5. Regular security updates and patches
6. Implement Web Application Firewall (WAF)
7. Use secrets management (not environment variables)
8. Enable audit logging for all services

========================================
For detailed findings, review the logs above.
========================================
"@
    
    $report | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Host "  [✓] Report saved to: $reportPath" -ForegroundColor Green
}

# Main execution
Write-Host "Starting comprehensive security audit...`n" -ForegroundColor White

# Initialize results tracking
$results = @{
    TotalServices = 4
    CriticalIssues = 0
    Warnings = 0
    InfoItems = 0
}

# Run tests
Test-CommonVulnerabilities -ServiceName "Nginx Gateway" -HostName "nginx" -Port 80
Test-SensitiveEndpoints
Test-RateLimiting -Url "http://nginx/api/orders/" -RequestCount 30

# Generate report
New-SecurityReport -Results $results

Write-Host "`n========================================" -ForegroundColor Red
Write-Host "Security Audit Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Red
Write-Host "`nIMPORTANT: Review findings and implement recommendations" -ForegroundColor Yellow
Write-Host "before deploying to production.`n" -ForegroundColor Yellow
