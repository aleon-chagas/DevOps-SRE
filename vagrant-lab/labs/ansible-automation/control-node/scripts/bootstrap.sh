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

# Set timezone
print_status "Setting timezone..."
sudo timedatectl set-timezone America/Sao_Paulo >/dev/null 2>&1

# Set hostname (keeps current hostname)
print_status "Setting hostname..."
sudo hostnamectl set-hostname $(hostname) >/dev/null 2>&1

print_status "Initial system setup completed!"