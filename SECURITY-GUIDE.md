# 🔐 Security & Network Monitoring Guide

## Overview

This project includes a comprehensive security and network monitoring toolkit integrated into the microservices stack. The `security-tools` container provides nmap, SNMP, PowerShell, and various network analysis tools.

---

## 🛠️ Available Tools

### 1. **nmap** - Network Mapper
- Port scanning and service discovery
- Vulnerability detection
- SSL/TLS certificate validation
- OS fingerprinting

### 2. **SNMP** - Simple Network Management Protocol  
- System metrics (CPU, memory, disk)
- Network interface statistics
- Real-time monitoring
- Performance data collection

### 3. **PowerShell 7+**
- Cross-platform automation
- API testing and health checks
- Security auditing
- Detailed reporting

### 4. **Network Tools**
- `tcpdump` - Packet capture and analysis
- `netstat` - Network connections
- `traceroute` - Path analysis
- `curl/wget` - HTTP testing
- `ngrep` - Network grep

---

## 🚀 Quick Start

### Start the Complete Stack
```powershell
docker-compose up --build -d
```

This will start:
- All microservices (Order, Reco, Inventory)
- Nginx gateway
- Prometheus + Grafana monitoring
- **Security-tools container** ✨ NEW!

### Access Security Tools Container
```powershell
docker exec -it security-tools bash
```

---

## 📜 Available Security Scripts

### 1. Network Discovery & Scanning
**Script:** `network-scan.sh`

Performs comprehensive network scanning of all services:

```powershell
docker exec -it security-tools bash /security-tools/scripts/network-scan.sh
```

**What it does:**
- ✅ Scans all backend services (ports 4000, 5000, 8000)
- ✅ Checks Nginx HTTP/HTTPS (ports 80, 443)
- ✅ Monitors Prometheus, Grafana, Nginx Exporter
- ✅ SSL/TLS certificate validation
- ✅ Vulnerability detection
- ✅ Network topology discovery

---

### 2. Service Health Monitoring (PowerShell)
**Script:** `monitor-services.ps1`

Monitors health and performance of all services:

```powershell
docker exec -it security-tools pwsh /security-tools/scripts/monitor-services.ps1
```

**Features:**
- 🟢 Real-time health checks
- ⏱️ Response time measurement
- 📊 Success rate calculation
- 📈 Prometheus metrics collection
- 🎨 Color-coded status display

**Sample Output:**
```
========================================
  E-Commerce Stack Monitoring Script
========================================

=== Service Health Check ===

[✓] Order Service is HEALTHY
    URL: http://order:4000/metrics
    Status: 200
  Response Time: 45ms

[✓] Nginx is HEALTHY
    URL: http://nginx:80/stub_status
    Status: 200
  Response Time: 12ms

Summary:
  Healthy Services: 6 / 6
  Success Rate: 100%
```

---

### 3. SNMP System Monitoring
**Script:** `snmp-monitor.sh`

Collects system metrics via SNMP protocol:

```powershell
docker exec -it security-tools bash /security-tools/scripts/snmp-monitor.sh
```

**Monitors:**
- 💻 System information (hostname, uptime, kernel)
- 🧠 CPU load and processes
- 💾 Memory usage
- 💿 Disk usage
- 🌐 Network interfaces and statistics
- 🔓 Open ports and active connections
- 🐳 Docker container status

---

### 4. Security Audit (PowerShell)
**Script:** `security-audit.ps1`

Comprehensive security vulnerability assessment:

```powershell
docker exec -it security-tools pwsh /security-tools/scripts/security-audit.ps1
```

**Security Checks:**
- 🔒 SSL/TLS configuration validation
- 🛡️ Security headers check (HSTS, XSS, CSP, etc.)
- ⚠️ Dangerous HTTP methods (TRACE, TRACK)
- 📁 Directory listing vulnerabilities
- 🔓 Exposed sensitive endpoints check
- 🚦 Rate limiting effectiveness test
- 📝 Automated security report generation

**Checks for Exposed Endpoints:**
- `/metrics` (Prometheus - Low Risk)
- `/admin` (Admin panel - CRITICAL)
- `/.env` (Environment file - CRITICAL)
- `/debug` (Debug endpoint - HIGH)
- `/actuator` (Spring Actuator - HIGH)
- `/swagger` (API docs - MEDIUM)

**Report Location:**
```
./security-tools/reports/security-audit-YYYY-MM-DD_HH-mm-ss.txt
```

---

### 5. Automated Monitoring (Continuous)
**Script:** `automated-monitor.ps1`

Runs periodic monitoring checks:

```powershell
docker exec -it security-tools pwsh /security-tools/scripts/automated-monitor.ps1 -IntervalSeconds 300
```

**Features:**
- 🔄 Continuous monitoring loop
- ⏲️ Configurable interval (default: 5 minutes)
- 📊 Combines all monitoring scripts
- 📝 Timestamped iterations
- 🛑 Ctrl+C to stop

---

## 🔍 Common Use Cases

### Daily Health Check
```powershell
# Quick overview of all services
docker exec -it security-tools pwsh /security-tools/scripts/monitor-services.ps1
```

### Pre-Deployment Security Audit
```powershell
# Before pushing to production
docker exec -it security-tools pwsh /security-tools/scripts/security-audit.ps1

# Review the generated report
docker exec -it security-tools cat /security-tools/reports/security-audit-*.txt
```

### Network Troubleshooting
```powershell
# Full network scan
docker exec -it security-tools bash /security-tools/scripts/network-scan.sh

# Check specific service
docker exec -it security-tools nmap -sV -p 4000 order
```

### Performance Monitoring
```powershell
# System metrics via SNMP
docker exec -it security-tools bash /security-tools/scripts/snmp-monitor.sh
```

---

## 📊 Manual Commands

### nmap Examples

```powershell
# Quick service discovery
docker exec -it security-tools nmap -sV order reco inventory

# Full vulnerability scan on Nginx
docker exec -it security-tools nmap -sV --script vuln nginx -p 80,443

# SSL certificate check
docker exec -it security-tools nmap --script ssl-cert nginx -p 443

# Detect OS and services
docker exec -it security-tools nmap -A nginx
```

### SNMP Queries

```powershell
# System description
docker exec -it security-tools snmpget -v2c -c public localhost 1.3.6.1.2.1.1.1.0

# System uptime
docker exec -it security-tools snmpget -v2c -c public localhost 1.3.6.1.2.1.1.3.0

# Network interfaces
docker exec -it security-tools snmpwalk -v2c -c public localhost 1.3.6.1.2.1.2.2.1.2

# CPU load (if available)
docker exec -it security-tools snmpwalk -v2c -c public localhost 1.3.6.1.4.1.2021.10
```

### PowerShell API Testing

```powershell
# Test order service endpoint
docker exec -it security-tools pwsh -Command "Invoke-WebRequest -Uri http://order:4000/metrics | Select-Object StatusCode, StatusDescription"

# Test all services health
docker exec -it security-tools pwsh -Command "$services = @('order:4000', 'reco:5000', 'inventory:8000'); foreach($s in $services) { try { $r = Invoke-WebRequest -Uri http://$s/metrics -UseBasicParsing -TimeoutSec 3; Write-Host \"$s : OK\" } catch { Write-Host \"$s : FAIL\" } }"

# Get Prometheus metrics
docker exec -it security-tools pwsh -Command "(Invoke-WebRequest -Uri http://prometheus:9090/api/v1/targets).Content | ConvertFrom-Json | ConvertTo-Json -Depth 10"
```

### Network Traffic Analysis

```powershell
# Capture HTTP traffic to order service (run for 60 seconds)
docker exec -it security-tools timeout 60 tcpdump -i any host order and port 4000 -w /security-tools/reports/order-traffic.pcap

# View live HTTP traffic
docker exec -it security-tools tcpdump -i any -A -s 0 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'

# Monitor connections to Nginx
docker exec -it security-tools tcpdump -i any host nginx -n
```

### Security Testing

```powershell
# Test rate limiting
docker exec -it security-tools pwsh -Command "1..50 | ForEach-Object { Invoke-WebRequest -Uri http://nginx/api/orders/ -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue }"

# Check for open ports
docker exec -it security-tools netstat -tuln | grep LISTEN

# Test SSL/TLS ciphers
docker exec -it security-tools bash -c "echo | openssl s_client -connect nginx:443 -cipher 'DES' 2>&1 | grep -E 'Cipher|error'"
```

---

## 📋 Security Checklist

Before deploying to production:

- [ ] Run full security audit: `security-audit.ps1`
- [ ] Verify all SSL/TLS certificates are valid
- [ ] Confirm rate limiting is active
- [ ] Check for exposed sensitive endpoints
- [ ] Validate security headers are set
- [ ] Review SNMP metrics for anomalies
- [ ] Scan for known vulnerabilities with nmap
- [ ] Ensure no directory listing is enabled
- [ ] Test authentication mechanisms
- [ ] Review security audit reports

---

## 🛡️ Security Best Practices

1. **Regular Scanning**
   - Schedule weekly network scans
   - Run security audits before each deployment
   - Monitor SNMP metrics continuously

2. **Respond to Findings**
   - Address CRITICAL issues immediately
   - Plan fixes for HIGH risk items
   - Document accepted risks

3. **Keep Tools Updated**
   ```powershell
   # Rebuild security-tools container with latest packages
   docker-compose build --no-cache security-tools
   docker-compose up -d security-tools
   ```

4. **Automated Monitoring**
   ```powershell
   # Run continuous monitoring in background
   docker exec -d security-tools pwsh /security-tools/scripts/automated-monitor.ps1 -IntervalSeconds 600
   ```

5. **Review Logs**
   ```powershell
   # Check security tools logs
   docker logs security-tools

   # View all security reports
   docker exec -it security-tools ls -lh /security-tools/reports/
   ```

---

## 🆘 Troubleshooting

### Container Not Starting
```powershell
# View logs
docker logs security-tools

# Restart container
docker-compose restart security-tools
```

### SNMP Not Responding
```powershell
# Start SNMP daemon
docker exec -it security-tools service snmpd start

# Check SNMP status
docker exec -it security-tools service snmpd status
```

### PowerShell Script Errors
```powershell
# Check PowerShell version
docker exec -it security-tools pwsh --version

# Test PowerShell
docker exec -it security-tools pwsh -Command "Write-Host 'PowerShell is working'"
```

### Permission Issues
```powershell
# Make scripts executable
docker exec -it security-tools bash -c "chmod +x /security-tools/scripts/*.sh"
docker exec -it security-tools bash -c "chmod +x /security-tools/scripts/*.ps1"
```

---

## 📚 Additional Resources

- [nmap Reference Guide](https://nmap.org/book/man.html)
- [SNMP OID Reference](http://www.net-snmp.org/docs/mibs/)
- [PowerShell Documentation](https://docs.microsoft.com/powershell/)
- [OWASP Security Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)

---

## 🎯 Next Steps

1. **Try the scripts** - Run each monitoring script to see the output
2. **Schedule audits** - Set up regular security scans
3. **Customize scripts** - Modify scripts for your specific needs
4. **Integrate CI/CD** - Add security checks to your deployment pipeline
5. **Add alerts** - Configure alerting based on security findings

---

**Note:** This is a development/testing environment. For production deployments, implement proper authentication, encryption, network segmentation, and access controls.

For more details, see `./security-tools/README.md`
