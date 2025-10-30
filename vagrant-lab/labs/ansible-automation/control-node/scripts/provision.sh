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

# Update system and install Ansible
print_status "Updating system and installing Ansible..."
sudo apt update -y >/dev/null 2>&1
sudo apt install software-properties-common -y && sudo add-apt-repository --yes --update ppa:ansible/ansible && sudo apt install ansible -y >/dev/null 2>&1

print_status "Provisioning completed successfully!"
