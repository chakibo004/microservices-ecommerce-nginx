#!/usr/bin/env pwsh
# PowerShell Script for Monitoring E-Commerce Microservices
# Author: Security Monitoring Team

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  E-Commerce Stack Monitoring Script   " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Service definitions
$services = @(
    @{Name="Order Service"; Host="order"; Port=4000; Path="/metrics"},
    @{Name="Recommendation Service"; Host="reco"; Port=5000; Path="/metrics"},
    @{Name="Inventory Service"; Host="inventory"; Port=8000; Path="/metrics"},
    @{Name="Nginx"; Host="nginx"; Port=80; Path="/stub_status"},
    @{Name="Prometheus"; Host="prometheus"; Port=9090; Path="/-/healthy"},
    @{Name="Grafana"; Host="grafana"; Port=3000; Path="/api/health"}
)

# Function to check service health
function Test-ServiceHealth {
    param(
        [string]$ServiceName,
        [string]$HostName,
        [int]$Port,
        [string]$Path
    )
    
    $url = "http://${HostName}:${Port}${Path}"
    
    try {
        $response = Invoke-WebRequest -Uri $url -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        
        if ($response.StatusCode -eq 200) {
            Write-Host "[✓] " -ForegroundColor Green -NoNewline
            Write-Host "$ServiceName is HEALTHY" -ForegroundColor White
            Write-Host "    URL: $url" -ForegroundColor Gray
            Write-Host "    Status: $($response.StatusCode)" -ForegroundColor Gray
            return $true
        }
    }
    catch {
        Write-Host "[✗] " -ForegroundColor Red -NoNewline
        Write-Host "$ServiceName is DOWN or UNREACHABLE" -ForegroundColor White
        Write-Host "    URL: $url" -ForegroundColor Gray
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    
    Write-Host ""
}

# Function to get metrics from a service
function Get-ServiceMetrics {
    param(
        [string]$ServiceName,
        [string]$HostName,
        [int]$Port
    )
    
    $url = "http://${HostName}:${Port}/metrics"
    
    try {
        $response = Invoke-WebRequest -Uri $url -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        $metrics = $response.Content
        
        Write-Host "`n--- Metrics for $ServiceName ---" -ForegroundColor Yellow
        
        # Parse and display key metrics
        $lines = $metrics -split "`n" | Where-Object { $_ -notmatch "^#" -and $_ -ne "" }
        $lines | Select-Object -First 10 | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Cyan
        }
        
        if ($lines.Count -gt 10) {
            Write-Host "  ... (showing 10 of $($lines.Count) metrics)" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "Could not retrieve metrics from $ServiceName" -ForegroundColor Red
    }
}

# Function to analyze response times
function Test-ServiceResponseTime {
    param(
        [string]$ServiceName,
        [string]$Url
    )
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        $null = Invoke-WebRequest -Uri $Url -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        $stopwatch.Stop()
        
        $responseTime = $stopwatch.ElapsedMilliseconds
        
        $color = if ($responseTime -lt 100) { "Green" } 
                 elseif ($responseTime -lt 500) { "Yellow" }
                 else { "Red" }
        
        Write-Host "  Response Time: " -NoNewline
        Write-Host "${responseTime}ms" -ForegroundColor $color
        
        return $responseTime
    }
    catch {
        Write-Host "  Response Time: TIMEOUT" -ForegroundColor Red
        return -1
    }
}

# Main monitoring loop
Write-Host "`n=== Service Health Check ===" -ForegroundColor Cyan
Write-Host ""

$healthyCount = 0
$totalServices = $services.Count

foreach ($service in $services) {
    $isHealthy = Test-ServiceHealth -ServiceName $service.Name -HostName $service.Host -Port $service.Port -Path $service.Path
    
    if ($isHealthy) {
        $healthyCount++
        Test-ServiceResponseTime -ServiceName $service.Name -Url "http://$($service.Host):$($service.Port)$($service.Path)"
    }
    
    Write-Host ""
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor White
Write-Host "  Healthy Services: $healthyCount / $totalServices" -ForegroundColor $(if ($healthyCount -eq $totalServices) { "Green" } else { "Yellow" })
Write-Host "  Success Rate: $([math]::Round(($healthyCount / $totalServices) * 100, 2))%" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan

# Optional: Get detailed metrics from one service
Write-Host "`nWould you like to see detailed metrics? (y/n)" -ForegroundColor Yellow
# Uncomment below for interactive mode
# $choice = Read-Host
# if ($choice -eq "y") {
#     Get-ServiceMetrics -ServiceName "Order Service" -Host "order" -Port 4000
# }

Write-Host "`nMonitoring complete!" -ForegroundColor Green
