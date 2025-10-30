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

# Configure /etc/hosts
print_status "Configuring /etc/hosts..."
cat << EOF | sudo tee /etc/hosts >/dev/null
127.0.0.1 localhost
10.0.0.2 srv-vm-cn01
10.0.0.3 srv-vm-app01
10.0.0.4 srv-vm-db01
EOF

# Copy hosts for ies user
print_status "Copying hosts file for user ies..."
sudo mkdir -p /home/ies/.ssh >/dev/null 2>&1
sudo cp /etc/hosts /home/ies/.ssh/hosts >/dev/null 2>&1
sudo chown ies:ies /home/ies/.ssh/hosts >/dev/null 2>&1
sudo chmod 600 /home/ies/.ssh/hosts >/dev/null 2>&1

# Configure DNS
print_status "Configuring DNS..."
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf >/dev/null 2>&1
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf >/dev/null 2>&1

# Set hostname
print_status "Setting hostname..."
sudo hostnamectl set-hostname srv-vm-app01 >/dev/null 2>&1

print_status "Network configuration completed!"