#!/usr/bin/env bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print status message
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# System verification script
print_status "Verifying system configuration..."

# Basic system info
print_status "System information:"
hostname >/dev/null 2>&1
cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f 2 >/dev/null 2>&1
uname -r >/dev/null 2>&1
uname -m >/dev/null 2>&1

# Network info
print_status "Network configuration:"
ip addr show | grep -w inet | grep -v 127.0.0.1 >/dev/null 2>&1
cat /etc/resolv.conf >/dev/null 2>&1

# User info
print_status "Current user:"
id >/dev/null 2>&1
groups >/dev/null 2>&1

# Sudo check
print_status "Checking sudo access:"
sudo -l >/dev/null 2>&1

print_status "Verification completed!"