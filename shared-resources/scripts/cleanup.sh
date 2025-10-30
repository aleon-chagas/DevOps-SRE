#!/bin/bash
# Cleanup script for DevOps/SRE labs

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

cleanup_docker() {
    log_warn "Cleaning up Docker resources..."
    
    if command -v docker >/dev/null; then
        # Remove stopped containers
        docker container prune -f >/dev/null 2>&1 || true
        
        # Remove unused images
        docker image prune -f >/dev/null 2>&1 || true
        
        # Remove unused volumes
        docker volume prune -f >/dev/null 2>&1 || true
        
        # Remove unused networks
        docker network prune -f >/dev/null 2>&1 || true
        
        log_info "Docker cleanup completed"
    else
        log_warn "Docker not found, skipping Docker cleanup"
    fi
}

cleanup_k8s() {
    log_warn "Cleaning up Kubernetes resources..."
    
    if command -v kubectl >/dev/null && kubectl cluster-info >/dev/null 2>&1; then
        # Remove completed jobs
        kubectl delete jobs --field-selector status.successful=1 --all-namespaces >/dev/null 2>&1 || true
        
        # Remove failed pods
        kubectl delete pods --field-selector status.phase=Failed --all-namespaces >/dev/null 2>&1 || true
        
        # Remove evicted pods
        kubectl get pods --all-namespaces --field-selector status.phase=Failed -o json | \
        jq -r '.items[] | select(.status.reason == "Evicted") | "\(.metadata.namespace) \(.metadata.name)"' | \
        while read namespace pod; do
            kubectl delete pod "$pod" -n "$namespace" >/dev/null 2>&1 || true
        done 2>/dev/null || true
        
        log_info "Kubernetes cleanup completed"
    else
        log_warn "Kubernetes not accessible, skipping K8s cleanup"
    fi
}

cleanup_logs() {
    log_warn "Cleaning up log files..."
    
    # Clean systemd logs older than 7 days
    sudo journalctl --vacuum-time=7d >/dev/null 2>&1 || true
    
    # Clean old log files
    find /var/log -name "*.log" -mtime +7 -delete 2>/dev/null || true
    find /tmp -name "*.log" -mtime +1 -delete 2>/dev/null || true
    
    log_info "Log cleanup completed"
}

cleanup_temp_files() {
    log_warn "Cleaning up temporary files..."
    
    # Clean /tmp files older than 1 day
    find /tmp -type f -mtime +1 -delete 2>/dev/null || true
    
    # Clean user temp files
    rm -rf ~/.cache/pip/* 2>/dev/null || true
    rm -rf ~/.npm/_cacache/* 2>/dev/null || true
    
    log_info "Temporary files cleanup completed"
}

main() {
    echo "🧹 DevOps/SRE Labs Cleanup"
    echo "=========================="
    
    log_error "⚠️  This will clean up Docker, Kubernetes, logs and temp files!"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup_docker
        cleanup_k8s
        cleanup_logs
        cleanup_temp_files
        
        echo
        log_info "Cleanup completed!"
    else
        log_info "Cleanup cancelled"
    fi
}

main "$@"