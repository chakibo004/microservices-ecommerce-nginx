#!/bin/bash
# Network Discovery and Scanning Script

echo "==================================="
echo "Network Security Scan - E-Commerce Stack"
echo "==================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to scan a specific service
scan_service() {
    local service_name=$1
    local service_host=$2
    local service_port=$3
    
    echo -e "${YELLOW}Scanning ${service_name}...${NC}"
    echo "Host: ${service_host}:${service_port}"
    
    # Basic port scan
    nmap -sV -p ${service_port} ${service_host}
    
    # Check if service is responsive
    if nc -zv ${service_host} ${service_port} 2>&1 | grep -q "succeeded"; then
        echo -e "${GREEN}✓ ${service_name} is UP${NC}"
    else
        echo -e "${RED}✗ ${service_name} is DOWN${NC}"
    fi
    echo ""
}

# Scan all microservices
echo "=== Backend Services Scan ==="
scan_service "Order Service" "order" "4000"
scan_service "Recommendation Service" "reco" "5000"
scan_service "Inventory Service" "inventory" "8000"

echo "=== Edge & Gateway Scan ==="
scan_service "Nginx HTTP" "nginx" "80"
scan_service "Nginx HTTPS" "nginx" "443"

echo "=== Monitoring Services Scan ==="
scan_service "Prometheus" "prometheus" "9090"
scan_service "Grafana" "grafana" "3000"
scan_service "Nginx Exporter" "nginx-exporter" "9113"

# Network topology discovery
echo "=== Network Topology Discovery ==="
echo "Available networks:"
docker network ls

# Perform vulnerability scan on Nginx
echo ""
echo "=== Nginx Vulnerability Scan ==="
nmap -sV --script vuln nginx -p 80,443 2>/dev/null || echo "Detailed vuln scan requires elevated privileges"

# SSL/TLS analysis
echo ""
echo "=== SSL/TLS Certificate Check ==="
echo | openssl s_client -connect nginx:443 -servername localhost 2>/dev/null | openssl x509 -noout -text | grep -A 2 "Validity"

echo ""
echo "==================================="
echo "Scan Complete!"
echo "==================================="
