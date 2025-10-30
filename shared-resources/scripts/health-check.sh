#!/bin/bash
# Script de health check para labs DevOps/SRE
# Criado por: Aleon Chagas
# Objetivo: Verificar saúde dos componentes da infraestrutura
# Uso: ./health-check.sh
#
# Este script verifica:
# - Status do cluster Kubernetes
# - Saúde da aplicação Weather App
# - Funcionamento do stack de monitoramento
# - Conectividade de APIs e serviços

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[✓]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }

check_k8s_cluster() {
    log_info "Checking Kubernetes cluster..."
    
    if kubectl get nodes >/dev/null 2>&1; then
        NODES=$(kubectl get nodes --no-headers | wc -l)
        READY_NODES=$(kubectl get nodes --no-headers | grep -c " Ready ")
        log_info "Cluster: $READY_NODES/$NODES nodes ready"
    else
        log_error "Kubernetes cluster not accessible"
        return 1
    fi
}

check_weather_app() {
    log_info "Checking Weather App..."
    
    if kubectl get pods -n weather-app >/dev/null 2>&1; then
        PODS=$(kubectl get pods -n weather-app --no-headers | wc -l)
        READY_PODS=$(kubectl get pods -n weather-app --no-headers | grep -c " Running ")
        log_info "Weather App: $READY_PODS/$PODS pods running"
        
        # Test API endpoint
        if command -v curl >/dev/null; then
            if curl -s http://localhost:30080/api/health >/dev/null; then
                log_info "Weather App API responding"
            else
                log_warn "Weather App API not responding"
            fi
        fi
    else
        log_warn "Weather App namespace not found"
    fi
}

check_monitoring() {
    log_info "Checking Monitoring stack..."
    
    if kubectl get pods -n monitoring >/dev/null 2>&1; then
        PODS=$(kubectl get pods -n monitoring --no-headers | wc -l)
        READY_PODS=$(kubectl get pods -n monitoring --no-headers | grep -c " Running ")
        log_info "Monitoring: $READY_PODS/$PODS pods running"
    else
        log_warn "Monitoring namespace not found"
    fi
}

main() {
    echo "🔍 DevOps/SRE Labs Health Check"
    echo "================================"
    
    check_k8s_cluster
    check_weather_app
    check_monitoring
    
    echo
    log_info "Health check completed!"
}

main "$@"