#!/usr/bin/env pwsh
# Automated Security & Network Monitoring Scheduler
# Runs periodic checks and saves reports

param(
    [int]$IntervalSeconds = 300  # Default: 5 minutes
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Automated Monitoring Scheduler      " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Monitoring interval: $IntervalSeconds seconds" -ForegroundColor White
Write-Host "Press Ctrl+C to stop monitoring`n" -ForegroundColor Yellow

$iteration = 1

while ($true) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "Monitoring Iteration #$iteration" -ForegroundColor Green
    Write-Host "Timestamp: $timestamp" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green
    
    # Run health check
    Write-Host "[1/3] Running service health check..." -ForegroundColor Yellow
    & pwsh /security-tools/scripts/monitor-services.ps1
    
    Write-Host "`n[2/3] Running network scan..." -ForegroundColor Yellow
    & bash /security-tools/scripts/network-scan.sh
    
    Write-Host "`n[3/3] Checking SNMP metrics..." -ForegroundColor Yellow
    & bash /security-tools/scripts/snmp-monitor.sh
    
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "Iteration #$iteration complete" -ForegroundColor Green
    Write-Host "Next check in $IntervalSeconds seconds..." -ForegroundColor Gray
    Write-Host "========================================`n" -ForegroundColor Green
    
    $iteration++
    Start-Sleep -Seconds $IntervalSeconds
}
