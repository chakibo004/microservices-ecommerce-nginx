# 📚 Documentation Index

## Quick Navigation

| Document | Description | When to Use |
|----------|-------------|-------------|
| **[INTEGRATION-SUMMARY.md](INTEGRATION-SUMMARY.md)** | Complete overview of all features | Start here! |
| **[SECURITY-GUIDE.md](SECURITY-GUIDE.md)** | Comprehensive security tools guide | Detailed usage and examples |
| **[WINDOWS-COMMANDS.md](WINDOWS-COMMANDS.md)** | Windows PowerShell quick reference | Daily commands for Windows users |
| **[WHATS-NEW.md](WHATS-NEW.md)** | New features overview | See what was added |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | System architecture diagrams | Understand the system |
| **[security-tools/README.md](security-tools/README.md)** | Security tools documentation | Tool-specific details |
| **[README.md](README.md)** | Main project documentation | Original project info |

---

## 🚀 Quick Start Guide

### For First-Time Users
1. Read **[INTEGRATION-SUMMARY.md](INTEGRATION-SUMMARY.md)** - Get an overview
2. Read **[WHATS-NEW.md](WHATS-NEW.md)** - Understand what's available
3. Check **[WINDOWS-COMMANDS.md](WINDOWS-COMMANDS.md)** - Run your first commands
4. Explore **[SECURITY-GUIDE.md](SECURITY-GUIDE.md)** - Learn all features

### For Windows Users
- **[WINDOWS-COMMANDS.md](WINDOWS-COMMANDS.md)** has all PowerShell commands
- Copy-paste ready examples
- Troubleshooting tips

### For Security Professionals
- **[SECURITY-GUIDE.md](SECURITY-GUIDE.md)** - Complete security toolkit
- **[security-tools/README.md](security-tools/README.md)** - Tool details
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Security architecture

### For Developers
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Understand the system
- **[SECURITY-GUIDE.md](SECURITY-GUIDE.md)** - API testing examples
- **[README.md](README.md)** - Microservices details

---

## 📖 Documentation by Topic

### Security
- [Security Guide](SECURITY-GUIDE.md) - Complete security documentation
- [Security Tools README](security-tools/README.md) - Tool-specific guides
- [Windows Commands](WINDOWS-COMMANDS.md) - Security testing commands

### Network Monitoring
- [Security Guide - Network Section](SECURITY-GUIDE.md#-network-discovery-nmap)
- [SNMP Monitoring](SECURITY-GUIDE.md#3-snmp-system-monitoring)
- [Architecture Diagrams](ARCHITECTURE.md)

### Automation
- [PowerShell Scripts](SECURITY-GUIDE.md#2-service-health-monitoring-powershell)
- [Automated Monitoring](SECURITY-GUIDE.md#5-automated-monitoring-continuous)
- [Windows Commands](WINDOWS-COMMANDS.md)

### Architecture
- [System Architecture](ARCHITECTURE.md)
- [Request Flow](ARCHITECTURE.md#-request-flow-example)
- [Security Layers](ARCHITECTURE.md#️-security-layers)

---

## 🎯 Documentation by Skill Level

### Beginner
1. Start: [INTEGRATION-SUMMARY.md](INTEGRATION-SUMMARY.md)
2. Try: [WINDOWS-COMMANDS.md](WINDOWS-COMMANDS.md) - Quick Start section
3. Learn: [WHATS-NEW.md](WHATS-NEW.md)

### Intermediate
1. Deep dive: [SECURITY-GUIDE.md](SECURITY-GUIDE.md)
2. Understand: [ARCHITECTURE.md](ARCHITECTURE.md)
3. Customize: [security-tools/README.md](security-tools/README.md)

### Advanced
1. Extend scripts: [security-tools/scripts/](security-tools/scripts/)
2. CI/CD integration: [INTEGRATION-SUMMARY.md](INTEGRATION-SUMMARY.md#-integration-points)
3. Custom monitoring: [SECURITY-GUIDE.md](SECURITY-GUIDE.md#-customization)

---

## 🔍 Find Specific Information

### How do I...

#### Run a network scan?
→ [WINDOWS-COMMANDS.md - Quick Security Checks](WINDOWS-COMMANDS.md#-quick-security-checks)

#### Check service health?
→ [SECURITY-GUIDE.md - Service Health Monitoring](SECURITY-GUIDE.md#2-service-health-monitoring-powershell)

#### Run a security audit?
→ [SECURITY-GUIDE.md - Security Audit](SECURITY-GUIDE.md#4-security-audit-powershell)

#### Monitor with SNMP?
→ [SECURITY-GUIDE.md - SNMP Monitoring](SECURITY-GUIDE.md#3-snmp-system-monitoring)

#### Use PowerShell scripts?
→ [WINDOWS-COMMANDS.md - Manual Testing Commands](WINDOWS-COMMANDS.md#-manual-testing-commands)

#### Understand the architecture?
→ [ARCHITECTURE.md](ARCHITECTURE.md)

#### Troubleshoot issues?
→ [SECURITY-GUIDE.md - Troubleshooting](SECURITY-GUIDE.md#-troubleshooting)
→ [WINDOWS-COMMANDS.md - Troubleshooting](WINDOWS-COMMANDS.md#-troubleshooting)

#### Set up continuous monitoring?
→ [SECURITY-GUIDE.md - Automated Monitoring](SECURITY-GUIDE.md#5-automated-monitoring-continuous)

#### View security reports?
→ [SECURITY-GUIDE.md - Report Generation](SECURITY-GUIDE.md#-report-generation)

#### Customize scripts?
→ [INTEGRATION-SUMMARY.md - Customization](INTEGRATION-SUMMARY.md#️-customization)

---

## 📋 Cheat Sheets

### Essential Commands
```powershell
# Start everything
docker-compose up -d

# Network scan
docker exec -it security-tools bash /security-tools/scripts/network-scan.sh

# Health check
docker exec -it security-tools pwsh /security-tools/scripts/monitor-services.ps1

# Security audit
docker exec -it security-tools pwsh /security-tools/scripts/security-audit.ps1

# SNMP monitoring
docker exec -it security-tools bash /security-tools/scripts/snmp-monitor.sh
```

More commands: [WINDOWS-COMMANDS.md](WINDOWS-COMMANDS.md)

---

## 🎓 Learning Path

### Day 1: Getting Started
- [ ] Read [INTEGRATION-SUMMARY.md](INTEGRATION-SUMMARY.md)
- [ ] Start the stack: `docker-compose up -d`
- [ ] Run first scan using [WINDOWS-COMMANDS.md](WINDOWS-COMMANDS.md)

### Day 2: Explore Tools
- [ ] Read [SECURITY-GUIDE.md](SECURITY-GUIDE.md)
- [ ] Try all 5 scripts
- [ ] Review generated reports

### Day 3: Understand System
- [ ] Read [ARCHITECTURE.md](ARCHITECTURE.md)
- [ ] Explore request flows
- [ ] Understand security layers

### Day 4: Customize
- [ ] Modify scripts in `security-tools/scripts/`
- [ ] Add custom checks
- [ ] Set up automated monitoring

### Day 5: Practice
- [ ] Run daily health checks
- [ ] Perform security audit
- [ ] Analyze SNMP metrics
- [ ] Generate reports

---

## 🔗 External Resources

### Tools Documentation
- [nmap Official Docs](https://nmap.org/book/man.html)
- [SNMP Documentation](http://www.net-snmp.org/docs/)
- [PowerShell Docs](https://docs.microsoft.com/powershell/)

### Learning Resources
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [Nginx Security](https://nginx.org/en/docs/http/ngx_http_secure_link_module.html)

---

## 📱 Access Points

Once running, access:
- **UI:** https://localhost/ui/
- **Prometheus:** http://localhost:9090
- **Grafana:** http://localhost:3001
- **APIs:** https://localhost/api/{orders|reco|inventory}/

---

## ✨ What's Next?

After reading the documentation:
1. **Start the system** - Follow [INTEGRATION-SUMMARY.md](INTEGRATION-SUMMARY.md)
2. **Run the scripts** - Use [WINDOWS-COMMANDS.md](WINDOWS-COMMANDS.md)
3. **Learn deeply** - Study [SECURITY-GUIDE.md](SECURITY-GUIDE.md)
4. **Understand architecture** - Review [ARCHITECTURE.md](ARCHITECTURE.md)
5. **Customize** - Modify scripts to your needs

---

## 🆘 Need Help?

1. Check the specific document for your topic
2. Review troubleshooting sections
3. Verify commands in [WINDOWS-COMMANDS.md](WINDOWS-COMMANDS.md)
4. Check Docker logs: `docker logs security-tools`

---

**Happy Learning! 🎉**

Start with [INTEGRATION-SUMMARY.md](INTEGRATION-SUMMARY.md) for a complete overview!
