#!/bin/bash

# ================================================================
# Kali Network & System Validation Suite
# Author: Internal Security Operations
# Purpose: Verify installation of key security toolkits, validate
#          network performance, and perform system diagnostics.
# ================================================================

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root."
    exit 1
fi

echo "[INFO] Updating package lists..."
apt-get update -y

echo "[STEP 1] Security Toolkit Verification and Installation"
sudo apt purge nmap -y
sudo apt install commix* kali-linux-default* kali-linux-headless* kali-tools-top10* legion* metasploit-framework* msfpc* netexec* nmap* python3-libnmap* set* unicorn-magic* zenmap* -y
sudo apt purge metasploit* -y
sudo apt install commix* kali-linux-default* kali-linux-headless* kali-tools-top10* legion* metasploit-framework* msfpc* set* unicorn-magic* -y

# Install other tools required for diagnostics
echo "[INFO] Installing supplementary diagnostic utilities..."
apt-get install -y tcpdump tshark curl iperf3 stress-ng dstat util-linux coreutils

echo "[STEP 2] Network Diagnostics"
echo "[INFO] Capturing packets on all interfaces for analysis..."
tcpdump -vvv -c 100 -i any -n not port 22

echo "[INFO] Protocol dissection with Wireshark CLI..."
tshark -V -c 50 -i any

echo "[STEP 3] Targeted Port and Service Scan"
nmap -d4 -T4 localhost

echo "[STEP 4] Bandwidth and Throughput Tests"
iperf3 -c iperf3-server.linode.com -t 15 -i 1

echo "[STEP 5] HTTP Response and Transfer Validation"
curl -L --trace-ascii - https://speed.hetzner.de/100MB.bin -o /dev/null --max-time 30

echo "[STEP 6] Controlled System Load Simulation"
stress-ng --cpu 2 --io 2 --vm 1 --vm-bytes 128M --timeout 60s --metrics-brief

echo "[STEP 7] Real-Time System Monitoring Snapshot"
dstat -tcmndrylpg --net-packets --fs --ipc --socket --tcp --udp --raw 5 6

echo "[STEP 8] Process Utilization Summary"
ps aux --sort=-%cpu | head -n 15

echo "[COMPLETE] Network and system validation sequence finished."
