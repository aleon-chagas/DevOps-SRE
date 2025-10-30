#!/bin/bash
# Script de backup para labs DevOps/SRE
# Criado por: Aleon Chagas
# Objetivo: Fazer backup de recursos Kubernetes e configurações importantes
# Uso: ./backup.sh
#
# Este script realiza backup de:
# - Recursos Kubernetes (namespaces, deployments, services)
# - Configurações (kubeconfig, SSH config)
# - Limpeza automática de backups antigos (>7 dias)

set -euo pipefail

BACKUP_DIR="${HOME}/devops-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

backup_k8s_resources() {
    log_step "Backing up Kubernetes resources..."
    
    mkdir -p "${BACKUP_DIR}/k8s-${TIMESTAMP}"
    
    # Backup all namespaces
    kubectl get namespaces -o yaml > "${BACKUP_DIR}/k8s-${TIMESTAMP}/namespaces.yaml"
    
    # Backup weather-app namespace
    if kubectl get namespace weather-app >/dev/null 2>&1; then
        kubectl get all -n weather-app -o yaml > "${BACKUP_DIR}/k8s-${TIMESTAMP}/weather-app.yaml"
    fi
    
    # Backup monitoring namespace
    if kubectl get namespace monitoring >/dev/null 2>&1; then
        kubectl get all -n monitoring -o yaml > "${BACKUP_DIR}/k8s-${TIMESTAMP}/monitoring.yaml"
    fi
    
    log_info "Kubernetes backup saved to: ${BACKUP_DIR}/k8s-${TIMESTAMP}/"
}

backup_configs() {
    log_step "Backing up configurations..."
    
    mkdir -p "${BACKUP_DIR}/configs-${TIMESTAMP}"
    
    # Backup kubeconfig
    if [[ -f ~/.kube/config ]]; then
        cp ~/.kube/config "${BACKUP_DIR}/configs-${TIMESTAMP}/kubeconfig"
    fi
    
    # Backup SSH config (if exists)
    if [[ -f ~/.ssh/config ]]; then
        cp ~/.ssh/config "${BACKUP_DIR}/configs-${TIMESTAMP}/ssh-config"
    fi
    
    log_info "Configs backup saved to: ${BACKUP_DIR}/configs-${TIMESTAMP}/"
}

cleanup_old_backups() {
    log_step "Cleaning up old backups (>7 days)..."
    
    if [[ -d "$BACKUP_DIR" ]]; then
        find "$BACKUP_DIR" -type d -name "*-*" -mtime +7 -exec rm -rf {} + 2>/dev/null || true
        log_info "Old backups cleaned up"
    fi
}

main() {
    echo "💾 DevOps/SRE Labs Backup"
    echo "=========================="
    
    mkdir -p "$BACKUP_DIR"
    
    backup_k8s_resources
    backup_configs
    cleanup_old_backups
    
    echo
    log_info "Backup completed! Location: $BACKUP_DIR"
}

main "$@"