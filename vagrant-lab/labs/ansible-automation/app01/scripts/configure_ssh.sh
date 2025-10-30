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

# Configure SSH settings
print_status "Configuring SSH..."
cat << EOF | sudo tee -a /etc/ssh/sshd_config >/dev/null 2>&1
PasswordAuthentication yes
PermitRootLogin no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

# Set SSH permissions
print_status "Setting SSH permissions..."
sudo chmod 700 /home/vagrant/.ssh >/dev/null 2>&1
sudo chmod 600 /home/vagrant/.ssh/authorized_keys >/dev/null 2>&1

# Restart SSH service
print_status "Restarting SSH service..."
sudo systemctl restart sshd >/dev/null 2>&1

print_status "SSH configuration completed!"