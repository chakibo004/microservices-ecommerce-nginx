#!/bin/bash
# SNMP Monitoring Script for Docker Containers
# This script monitors system metrics via SNMP

echo "==================================="
echo "SNMP Monitoring - System Metrics"
echo "==================================="
echo ""

# SNMP Community string (default: public)
COMMUNITY="public"

# Function to get SNMP data
get_snmp_data() {
    local oid=$1
    local description=$2
    local host=${3:-localhost}
    
    echo "=== $description ==="
    snmpget -v2c -c $COMMUNITY $host $oid 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "SNMP query failed. Ensure snmpd is running."
    fi
    echo ""
}

# Function to walk SNMP tree
walk_snmp_tree() {
    local oid=$1
    local description=$2
    local host=${3:-localhost}
    
    echo "=== $description ==="
    snmpwalk -v2c -c $COMMUNITY $host $oid 2>/dev/null | head -n 20
    if [ $? -ne 0 ]; then
        echo "SNMP walk failed. Ensure snmpd is running."
    else
        echo "(showing first 20 entries)"
    fi
    echo ""
}

# Check if snmpd is running
echo "Checking SNMP daemon status..."
if ! pgrep -x "snmpd" > /dev/null; then
    echo "Starting SNMP daemon..."
    service snmpd start 2>/dev/null || echo "Could not start snmpd. Running in limited mode."
fi

echo ""

# System Information
echo "=== SYSTEM INFORMATION ==="
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo ""

# Basic SNMP queries
# System Description
get_snmp_data "1.3.6.1.2.1.1.1.0" "System Description"

# System Uptime
get_snmp_data "1.3.6.1.2.1.1.3.0" "System Uptime"

# System Contact
get_snmp_data "1.3.6.1.2.1.1.4.0" "System Contact"

# System Name
get_snmp_data "1.3.6.1.2.1.1.5.0" "System Name"

# Network Interfaces
walk_snmp_tree "1.3.6.1.2.1.2.2.1.2" "Network Interfaces"

# CPU Load (if available)
echo "=== CPU LOAD ==="
top -bn1 | grep "Cpu(s)" || echo "CPU info not available"
echo ""

# Memory Usage
echo "=== MEMORY USAGE ==="
free -h
echo ""

# Disk Usage
echo "=== DISK USAGE ==="
df -h | grep -E "(Filesystem|/dev/)"
echo ""

# Network Statistics
echo "=== NETWORK STATISTICS ==="
netstat -i | head -n 10 || ip -s link show | head -n 20
echo ""

# Container-specific monitoring
echo "=== DOCKER CONTAINER MONITORING ==="
if command -v docker &> /dev/null; then
    echo "Docker containers status:"
    # This will work if Docker socket is mounted
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Docker socket not accessible from this container"
else
    echo "Docker CLI not available in this container"
fi
echo ""

# Security checks
echo "=== SECURITY CHECKS ==="
echo "Open ports:"
netstat -tuln | grep LISTEN | head -n 10
echo ""

echo "Active connections:"
netstat -tn | grep ESTABLISHED | head -n 10
echo ""

echo "==================================="
echo "SNMP Monitoring Complete!"
echo "==================================="
