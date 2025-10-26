# Security Tools & Network Monitoring

This directory contains security auditing and network monitoring tools for the e-commerce microservices stack.

## 🛠️ Available Tools

### 1. **nmap** - Network Discovery and Security Auditing
- Port scanning
- Service version detection
- Vulnerability scanning
- OS detection

### 2. **SNMP** - Simple Network Management Protocol
- System metrics monitoring
- Network device monitoring
- Performance data collection

### 3. **PowerShell** - Automation and Monitoring
- Service health checks
- Security audits
- Automated reporting
- API testing

### 4. **Additional Tools**
- `tcpdump` - Packet analyzer
- `netstat` - Network statistics
- `curl/wget` - HTTP testing
- `traceroute` - Network path analysis

---

## 📜 Available Scripts

### Network Scanning (`network-scan.sh`)
Performs comprehensive network discovery and port scanning:
```bash
docker exec -it security-tools bash /security-tools/scripts/network-scan.sh
```

**Features:**
- Scans all microservices (Order, Reco, Inventory)
- Checks Nginx gateway and monitoring tools
- SSL/TLS certificate validation
- Vulnerability detection

---

### SNMP Monitoring (`snmp-monitor.sh`)
Monitors system metrics via SNMP protocol:
```bash
docker exec -it security-tools bash /security-tools/scripts/snmp-monitor.sh
```

**Metrics:**
- System information (uptime, hostname)
- CPU and memory usage
- Network interfaces and statistics
- Disk usage
- Open ports and connections

---

### Service Monitoring - PowerShell (`monitor-services.ps1`)
Comprehensive service health monitoring:
```bash
docker exec -it security-tools pwsh /security-tools/scripts/monitor-services.ps1
```

**Features:**
- Health checks for all services
- Response time measurement
- Prometheus metrics collection
- Color-coded status reports
- Success rate calculation

---

### Security Audit - PowerShell (`security-audit.ps1`)
Full security vulnerability assessment:
```bash
docker exec -it security-tools pwsh /security-tools/scripts/security-audit.ps1
```

**Tests:**
- SSL/TLS configuration
- Security headers validation
- HTTP methods checking
- Directory listing vulnerabilities
- Exposed sensitive endpoints
- Rate limiting effectiveness
- Generates security reports

---

## 🚀 Quick Start Guide

### 1. Start the Stack
```bash
docker-compose up -d
```

### 2. Access Security Tools Container
```bash
docker exec -it security-tools bash
```

### 3. Run Network Scan
```bash
bash /security-tools/scripts/network-scan.sh
```

### 4. Monitor Services with PowerShell
```bash
pwsh /security-tools/scripts/monitor-services.ps1
```

### 5. Run Security Audit
```bash
pwsh /security-tools/scripts/security-audit.ps1
```

---

## 🔍 Common Use Cases

### Daily Health Check
```bash
# Quick health check of all services
docker exec -it security-tools pwsh /security-tools/scripts/monitor-services.ps1
```

### Network Discovery
```bash
# Discover all running services and open ports
docker exec -it security-tools bash /security-tools/scripts/network-scan.sh
```

### Security Assessment
```bash
# Before production deployment
docker exec -it security-tools pwsh /security-tools/scripts/security-audit.ps1
```

### SNMP Monitoring
```bash
# System metrics via SNMP
docker exec -it security-tools bash /security-tools/scripts/snmp-monitor.sh
```

---

## 📊 Sample Commands

### Manual nmap Scans
```bash
# Scan specific service
docker exec -it security-tools nmap -sV -p 4000 order

# Scan Nginx with script scanning
docker exec -it security-tools nmap -sV --script vuln nginx -p 80,443

# Quick scan all services
docker exec -it security-tools nmap -sn backend
```

### SNMP Queries
```bash
# Get system description
docker exec -it security-tools snmpget -v2c -c public localhost 1.3.6.1.2.1.1.1.0

# Walk network interfaces
docker exec -it security-tools snmpwalk -v2c -c public localhost 1.3.6.1.2.1.2.2.1.2
```

### PowerShell API Testing
```bash
# Test specific endpoint
docker exec -it security-tools pwsh -Command "Invoke-WebRequest -Uri http://order:4000/metrics"

# Test with authentication
docker exec -it security-tools pwsh -Command "Invoke-WebRequest -Uri http://nginx/api/orders/ -Headers @{'Authorization'='Bearer token'}"
```

### Packet Capture
```bash
# Capture HTTP traffic to order service
docker exec -it security-tools tcpdump -i any host order and port 4000 -w /security-tools/reports/capture.pcap

# View live traffic
docker exec -it security-tools tcpdump -i any -n
```

---

## 📝 Report Generation

Security audit reports are automatically saved to:
```
./security-tools/reports/security-audit-YYYY-MM-DD_HH-mm-ss.txt
```

Access reports:
```bash
# List all reports
docker exec -it security-tools ls -lh /security-tools/reports/

# View latest report
docker exec -it security-tools cat /security-tools/reports/security-audit-*.txt
```

---

## 🔐 Security Best Practices

1. **Regular Scanning**
   - Run network scans weekly
   - Perform security audits before deployments

2. **Monitor Metrics**
   - Use PowerShell monitoring for real-time health
   - Set up alerts for service failures

3. **Review Reports**
   - Analyze security audit reports
   - Address critical and high-risk findings

4. **Update Tools**
   - Keep nmap and security tools updated
   - Refresh vulnerability databases

---

## 🛡️ Security Considerations

- The security-tools container has access to all networks
- Docker socket access is optional (for advanced Docker operations)
- All scripts are mounted read-only for safety
- Reports directory is writable for audit logs

---

## 📚 Additional Resources

- [nmap Documentation](https://nmap.org/book/man.html)
- [SNMP MIBs Reference](http://www.net-snmp.org/docs/)
- [PowerShell Documentation](https://docs.microsoft.com/powershell/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)

---

## 🆘 Troubleshooting

### Container Not Starting
```bash
docker logs security-tools
docker-compose up security-tools
```

### Permission Issues
```bash
# Make scripts executable
docker exec -it security-tools chmod +x /security-tools/scripts/*.sh
docker exec -it security-tools chmod +x /security-tools/scripts/*.ps1
```

### SNMP Not Working
```bash
# Start SNMP daemon
docker exec -it security-tools service snmpd start
```

### PowerShell Issues
```bash
# Check PowerShell installation
docker exec -it security-tools pwsh --version
```

---

**Note:** This is a development/testing environment. For production use, implement proper authentication, encryption, and access controls.
