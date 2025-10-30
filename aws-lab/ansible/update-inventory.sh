#!/bin/bash
# Script para atualizar inventory com IPs das instâncias EC2

set -euo pipefail

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Diretório do Terraform
TERRAFORM_DIR="../terraform/main-stack"
INVENTORY_FILE="./deploy/env/aws/hosts"

log_step "Obtendo IPs das instâncias EC2..."

cd "$TERRAFORM_DIR"

# Sempre usar AWS CLI para obter IPs atuais
log_step "Consultando IPs atuais via AWS CLI..."

# Buscar instância Master
MASTER_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=*k8s-master*" "Name=instance-state-name,Values=running" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' --output text 2>/dev/null)

# Buscar IPs dos workers ordenados por nome
WORKER_IPS_RAW=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=*k8s-worker*" "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value|[0],PublicIpAddress]' \
    --output text | sort | awk '{print $2}')

# Converter para array
if [[ -n "$WORKER_IPS_RAW" ]]; then
    WORKER_IPS=()
    while IFS= read -r ip; do
        [[ -n "$ip" && "$ip" != "None" ]] && WORKER_IPS+=("$ip")
    done <<< "$WORKER_IPS_RAW"
else
    WORKER_IPS=()
fi

if [[ -z "$MASTER_IP" || "$MASTER_IP" == "null" ]]; then
    echo "Erro: Não foi possível obter IP do K8s Master"
    echo "Verifique se as instâncias estão rodando e têm IPs públicos"
    exit 1
fi

cd - > /dev/null

log_step "Atualizando inventory..."

# Criar novo inventory
cat > "$INVENTORY_FILE" << EOF
[master]
k8s-master ansible_host=$MASTER_IP

[workers]
EOF

# Adicionar workers
if [[ ${#WORKER_IPS[@]} -gt 0 ]]; then
    for i in "${!WORKER_IPS[@]}"; do
        echo "k8s-$((i+1)) ansible_host=${WORKER_IPS[i]}" >> "$INVENTORY_FILE"
    done
else
    log_info "Nenhum worker encontrado"
fi

# Adicionar grupos
cat >> "$INVENTORY_FILE" << EOF

[all:children]
master
workers
EOF

log_step "Atualizando SSH config..."

# Criar SSH config
SSH_CONFIG_FILE="./ssh.config"

cat > "$SSH_CONFIG_FILE" << EOF
Host k8s-master
    HostName $MASTER_IP
    User ubuntu
    IdentityFile ~/.ssh/ssh_keys/courses/devops2025.pem
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

EOF

# Adicionar workers ao SSH config
if [[ ${#WORKER_IPS[@]} -gt 0 ]]; then
    for i in "${!WORKER_IPS[@]}"; do
        cat >> "$SSH_CONFIG_FILE" << EOF
Host k8s-$((i+1))
    HostName ${WORKER_IPS[i]}
    User ubuntu
    IdentityFile ~/.ssh/ssh_keys/courses/devops2025.pem
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

EOF
    done
fi

# Adicionar configurações globais
cat >> "$SSH_CONFIG_FILE" << EOF
Host *
    TCPKeepAlive yes
    ControlMaster auto
    ControlPersist 180s
    ServerAliveInterval 180
EOF

log_info "Inventory e SSH config atualizados com sucesso!"
log_info "K8s Master: $MASTER_IP"
log_info "Workers encontrados: ${#WORKER_IPS[@]}"

echo
log_info "Inventory:"
cat "$INVENTORY_FILE"

echo
log_info "SSH Config:"
cat "$SSH_CONFIG_FILE"

echo
log_info "Comandos SSH disponíveis:"
echo "ssh k8s-master"
for i in "${!WORKER_IPS[@]}"; do
    echo "ssh k8s-$((i+1))"
done