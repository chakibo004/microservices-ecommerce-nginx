# 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          EXTERNAL ACCESS                                 │
│                                                                          │
│  Browser/Client  ──────────┐                                            │
│  (Windows)                 │                                            │
│                            │                                            │
│  PowerShell Scripts ───────┤                                            │
│  nmap/SNMP Tools ──────────┤                                            │
└────────────────────────────┼──────────────────────────────────────────┘
                             │
                             │ HTTPS (443) / HTTP (80)
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          🛡️ NGINX (API GATEWAY)                         │
│  - Reverse Proxy                                                         │
│  - SSL/TLS Termination                                                   │
│  - Load Balancing (Round Robin, Least Conn, IP Hash)                   │
│  - Rate Limiting (10 req/s per IP)                                      │
│  - Caching (10 min for reco, 5 min for inventory)                      │
│  - Security Headers (HSTS, XSS Protection, etc.)                        │
│  - Compression (Gzip)                                                    │
│                                                                          │
│  Routes:                                                                 │
│  /api/orders/     ──→ Order Service                                     │
│  /api/reco/       ──→ Recommendation Service                            │
│  /api/inventory/  ──→ Inventory Service                                 │
│  /ui/             ──→ Static HTML Interface                             │
│  /stub_status     ──→ Nginx Metrics                                     │
└──────────┬──────────────────┬──────────────────┬────────────────────────┘
           │                  │                  │
           │  Backend Network │                  │ Monitoring Network
           │                  │                  │
    ┌──────▼──────┐   ┌──────▼──────┐   ┌──────▼──────┐
    │             │   │             │   │             │
    │   Order     │   │    Reco     │   │  Inventory  │
    │  Service    │   │   Service   │   │   Service   │
    │             │   │             │   │             │
    │  Node.js    │   │   Python    │   │     Go      │
    │  Port 4000  │   │  Port 5000  │   │  Port 8000  │
    │             │   │             │   │             │
    │  2 Replicas │   │  1 Instance │   │  1 Instance │
    │  (Round     │   │  (Least     │   │  (IP Hash)  │
    │   Robin)    │   │   Conn)     │   │             │
    │             │   │             │   │             │
    │ /metrics    │   │ /metrics    │   │ /metrics    │
    └─────┬───────┘   └─────┬───────┘   └─────┬───────┘
          │                 │                 │
          └─────────────────┼─────────────────┘
                            │
                            │ Scrapes metrics every 15s
                            ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     📊 OBSERVABILITY STACK                               │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────┐      │
│  │  Prometheus (Port 9090)                                       │      │
│  │  - Scrapes all /metrics endpoints                             │      │
│  │  - Stores time-series data                                    │      │
│  │  - Provides query interface                                   │      │
│  └────────────────────────┬─────────────────────────────────────┘      │
│                           │                                             │
│                           │ PromQL queries                              │
│                           ▼                                             │
│  ┌──────────────────────────────────────────────────────────────┐      │
│  │  Grafana (Port 3001)                                          │      │
│  │  - Pre-configured dashboards                                  │      │
│  │  - nginx-dashboard.json                                       │      │
│  │  - ecom-dashboard.json                                        │      │
│  │  - Real-time visualization                                    │      │
│  └──────────────────────────────────────────────────────────────┘      │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────┐      │
│  │  Nginx Prometheus Exporter (Port 9113)                        │      │
│  │  - Scrapes /stub_status from Nginx                            │      │
│  │  - Exports to Prometheus format                               │      │
│  └──────────────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│              🔐 SECURITY & NETWORK MONITORING                            │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────┐      │
│  │  Security Tools Container                                     │      │
│  │                                                                │      │
│  │  📡 nmap                                                       │      │
│  │  - Network discovery                                          │      │
│  │  - Port scanning (all services)                               │      │
│  │  - Vulnerability detection                                    │      │
│  │  - SSL/TLS validation                                         │      │
│  │                                                                │      │
│  │  📊 SNMP                                                       │      │
│  │  - System metrics (CPU, memory, disk)                         │      │
│  │  - Network interface stats                                    │      │
│  │  - Performance monitoring                                     │      │
│  │                                                                │      │
│  │  🐚 PowerShell 7+                                             │      │
│  │  - Service health checks                                      │      │
│  │  - Response time measurement                                  │      │
│  │  - Security audits                                            │      │
│  │  - API testing                                                │      │
│  │  - Automated reporting                                        │      │
│  │                                                                │      │
│  │  🔧 Network Tools                                             │      │
│  │  - tcpdump (packet capture)                                   │      │
│  │  - netstat (connections)                                      │      │
│  │  - traceroute (path analysis)                                 │      │
│  │  - curl/wget (HTTP testing)                                   │      │
│  │                                                                │      │
│  │  Scripts:                                                      │      │
│  │  - network-scan.sh        (nmap scanning)                     │      │
│  │  - snmp-monitor.sh        (SNMP metrics)                      │      │
│  │  - monitor-services.ps1   (health checks)                     │      │
│  │  - security-audit.ps1     (security tests)                    │      │
│  │  - automated-monitor.ps1  (continuous monitoring)             │      │
│  └──────────────────────────────────────────────────────────────┘      │
│                                                                          │
│  Reports: ./security-tools/reports/                                     │
│  - security-audit-YYYY-MM-DD_HH-mm-ss.txt                               │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                        🌐 DOCKER NETWORKS                                │
│                                                                          │
│  Backend Network:                                                        │
│  - nginx                                                                 │
│  - order (x2 replicas)                                                   │
│  - reco                                                                  │
│  - inventory                                                             │
│  - security-tools                                                        │
│  - nginx-exporter                                                        │
│                                                                          │
│  Monitoring Network:                                                     │
│  - prometheus                                                            │
│  - grafana                                                               │
│  - nginx-exporter                                                        │
│  - All backend services (for metrics scraping)                          │
│  - security-tools                                                        │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                          💾 PERSISTENT STORAGE                           │
│                                                                          │
│  nginx_cache volume:                                                     │
│  - Stores Nginx proxy cache                                             │
│  - Survives container restarts                                          │
│                                                                          │
│  security-tools/reports:                                                 │
│  - Security audit reports                                                │
│  - Timestamped findings                                                  │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Request Flow Example

### User Creates an Order

```
1. Browser (Windows)
   └─> HTTPS POST https://localhost/api/orders/
       Body: { "item": "SKU-42", "qty": 2 }

2. Nginx Gateway
   ├─> SSL/TLS Decryption
   ├─> Rate Limiting Check (within 10 req/s?)
   ├─> Security Headers Added
   ├─> Load Balancing (Round Robin)
   └─> Proxy Pass to http://order:4000/

3. Order Service (Node.js)
   ├─> Receives request
   ├─> Validates input
   ├─> Creates order (in-memory)
   ├─> Updates Prometheus metrics
   │   - order_service_requests_total++
   │   - order_service_orders_total_count++
   └─> Returns JSON response

4. Nginx
   ├─> Receives response from order service
   ├─> Adds security headers
   ├─> Gzip compression
   └─> Returns to client

5. Prometheus
   └─> Scrapes /metrics from order service (every 15s)

6. Grafana
   └─> Queries Prometheus and displays in dashboard

7. Security Tools (if monitoring)
   ├─> Periodic health checks
   ├─> Response time measurement
   └─> Logs to reports
```

---

## 🔍 Security Monitoring Flow

### Network Scan Execution

```
1. Windows PowerShell
   └─> docker exec -it security-tools bash /security-tools/scripts/network-scan.sh

2. Security Tools Container
   ├─> nmap -sV -p 4000 order
   │   └─> Discovers: Node.js Express on port 4000
   │
   ├─> nmap -sV -p 5000 reco
   │   └─> Discovers: Python Flask on port 5000
   │
   ├─> nmap -sV -p 8000 inventory
   │   └─> Discovers: Go HTTP server on port 8000
   │
   ├─> nmap -sV -p 80,443 nginx
   │   └─> Discovers: Nginx 1.25, SSL certificate info
   │
   ├─> nmap --script vuln nginx
   │   └─> Checks for known vulnerabilities
   │
   └─> Reports results to stdout
```

### Security Audit Execution

```
1. Windows PowerShell
   └─> docker exec -it security-tools pwsh /security-tools/scripts/security-audit.ps1

2. PowerShell Script
   ├─> Test SSL/TLS Configuration
   │   └─> Invoke-WebRequest https://nginx:443
   │
   ├─> Check Security Headers
   │   └─> X-Frame-Options, HSTS, CSP, etc.
   │
   ├─> Test HTTP Methods
   │   └─> TRACE, TRACK, PUT, DELETE
   │
   ├─> Check for Exposed Endpoints
   │   └─> /metrics, /admin, /.env, /debug
   │
   ├─> Test Rate Limiting
   │   └─> Send 50 rapid requests
   │
   └─> Generate Report
       └─> ./security-tools/reports/security-audit-YYYY-MM-DD.txt
```

---

## 📊 Data Flow

### Metrics Collection

```
Backend Services → Prometheus → Grafana → User Dashboard
     ↑                ↑
     └────────────────┴─ Security Tools (monitoring)

Every 15 seconds:
- Prometheus scrapes /metrics from:
  - order:4000/metrics
  - reco:5000/metrics
  - inventory:8000/metrics
  - nginx-exporter:9113/metrics
  
- Security tools can query these endpoints on-demand
- PowerShell scripts fetch and analyze metrics
- Results stored in reports directory
```

---

## 🛡️ Security Layers

```
Layer 1: Network Edge
├─ Nginx SSL/TLS (443)
├─ Rate Limiting (10 req/s)
└─ HTTP → HTTPS redirect

Layer 2: Gateway
├─ Security Headers
├─ Request filtering
└─ Proxy buffering

Layer 3: Services
├─ Input validation
├─ Metrics exposure (/metrics)
└─ Health checks

Layer 4: Monitoring
├─ Prometheus metrics
├─ Grafana dashboards
└─ Security tools scanning

Layer 5: Network Isolation
├─ Backend network (internal)
├─ Monitoring network (metrics)
└─ No external access to services
```

---

## 🎯 Access Points Summary

| Service | Port | Access | Purpose |
|---------|------|--------|---------|
| Nginx HTTPS | 443 | External | Main entry point |
| Nginx HTTP | 80 | External | Redirects to HTTPS |
| Order Service | 4000 | Internal | Backend API |
| Reco Service | 5000 | Internal | Backend API |
| Inventory Service | 8000 | Internal | Backend API |
| Prometheus | 9090 | External | Metrics database |
| Grafana | 3001 | External | Dashboards |
| Nginx Exporter | 9113 | Internal | Nginx metrics |
| Security Tools | - | Container only | Interactive access |

---

This architecture provides:
- ✅ **High Availability** (multiple order service replicas)
- ✅ **Observability** (Prometheus + Grafana)
- ✅ **Security** (SSL, rate limiting, headers)
- ✅ **Performance** (caching, load balancing, compression)
- ✅ **Monitoring** (nmap, SNMP, PowerShell)
- ✅ **Scalability** (containerized, easy to scale)
- ✅ **Network Security** (isolated networks, scanning tools)
