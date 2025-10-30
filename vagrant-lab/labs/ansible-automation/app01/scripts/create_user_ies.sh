#!/bin/bash

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

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create ies user and set up environment
print_status "Creating user ies..."
sudo useradd -m -s /bin/bash ies >/dev/null 2>&1
PASSWORD=$(openssl rand -base64 12)
echo "ies:${PASSWORD}" | sudo chpasswd >/dev/null 2>&1

# Configure sudoers for ies
print_status "Configuring sudoers..."
echo "%sudo ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers >/dev/null 2>&1
sudo usermod -aG sudo ies >/dev/null 2>&1

# Set up SSH for ies
print_status "Setting up SSH for ies..."
sudo mkdir -p /home/ies/.ssh >/dev/null 2>&1
sudo cp /home/vagrant/.ssh/authorized_keys /home/ies/.ssh/ >/dev/null 2>&1
sudo chown -R ies:ies /home/ies/.ssh >/dev/null 2>&1
sudo chmod 700 /home/ies/.ssh >/dev/null 2>&1
sudo chmod 600 /home/ies/.ssh/authorized_keys >/dev/null 2>&1

# Set up .bashrc for ies
print_status "Configuring .bashrc for ies..."
cat << EOF | sudo tee /home/ies/.bashrc >/dev/null
alias ll='ls -la'
alias ..='cd ..'
alias ...='cd ../..'

PS1='\[\e[1;32m\][\u@\h \W]$\[\e[0m\] '

HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth
EOF
sudo chown ies:ies /home/ies/.bashrc >/dev/null 2>&1

print_status "User ies created and configured!"