# Security & Network Monitoring Container
FROM ubuntu:22.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install prerequisites for PowerShell
RUN apt-get update && apt-get install -y \
    wget \
    apt-transport-https \
    software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PowerShell from Microsoft repository
RUN wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y powershell \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install security and network tools
RUN apt-get update && apt-get install -y \
    nmap \
    snmp \
    snmpd \
    snmp-mibs-downloader \
    net-tools \
    iputils-ping \
    curl \
    tcpdump \
    dnsutils \
    netcat \
    traceroute \
    iptables \
    ngrep \
    apache2-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /security-tools

# Copy scripts
COPY ./scripts /security-tools/scripts

# Make scripts executable
RUN chmod +x /security-tools/scripts/*.sh 2>/dev/null || true
RUN chmod +x /security-tools/scripts/*.ps1 2>/dev/null || true

# Keep container running
CMD ["tail", "-f", "/dev/null"]
