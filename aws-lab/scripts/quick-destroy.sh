#!/bin/bash
set -euo pipefail

# Script de destruição rápida - apenas main stack
# Uso: ./scripts/quick-destroy.sh [dev|stg|prod]

ENVIRONMENT="${1:-dev}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

force_terminate_instances() {
    log_warn "Terminando instâncias EC2 imediatamente..."
    
    # Obter IDs das instâncias com tag do projeto
    INSTANCE_IDS=$(aws ec2 describe-instances \
        --filters "Name=tag:Project,Values=devops-aws" "Name=instance-state-name,Values=running,pending,stopping,stopped" \
        --query "Reservations[*].Instances[*].InstanceId" \
        --output text 2>/dev/null || echo "")
    
    if [[ -n "$INSTANCE_IDS" ]]; then
        log_info "Terminando instâncias: $INSTANCE_IDS"
        aws ec2 terminate-instances --instance-ids $INSTANCE_IDS || true
        
        # Aguardar terminação (mais rápido que stop)
        log_info "Aguardando terminação..."
        aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS --cli-read-timeout 180 || true
    else
        log_info "Nenhuma instância encontrada"
    fi
}

cleanup_security_groups() {
    log_warn "Limpando security groups órfãos..."
    
    # Remover security groups do projeto
    SG_IDS=$(aws ec2 describe-security-groups \
        --filters "Name=tag:Project,Values=devops-aws" \
        --query "SecurityGroups[?GroupName!='default'].GroupId" \
        --output text 2>/dev/null || echo "")
    
    if [[ -n "$SG_IDS" ]]; then
        for sg_id in $SG_IDS; do
            log_info "Removendo security group: $sg_id"
            aws ec2 delete-security-group --group-id "$sg_id" 2>/dev/null || true
        done
    fi
}

quick_destroy() {
    log_error "⚠️  DESTRUIÇÃO RÁPIDA - Ambiente: ${ENVIRONMENT}"
    read -p "Confirme digitando 'QUICK': " confirm

    if [[ "$confirm" != "QUICK" ]]; then
        log_info "Cancelado"
        exit 0
    fi

    # 1. Terminar instâncias imediatamente
    force_terminate_instances
    
    # 2. Limpar security groups
    cleanup_security_groups
    
    # 3. Terraform destroy otimizado
    log_warn "Executando terraform destroy..."
    cd ../terraform/main-stack

    terraform init -backend-config=backend.tfvars
    
    if [[ "${ENVIRONMENT}" == "dev" ]]; then
        terraform workspace select default 2>/dev/null || true
    else
        terraform workspace select "${ENVIRONMENT}" 2>/dev/null || true
    fi
    
    # Destroy super otimizado
    terraform destroy -var-file="environments/${ENVIRONMENT}.tfvars" \
        -auto-approve \
        -parallelism=20 \
        -refresh=false \
        -target=module.ec2_instances \
        -target=aws_security_group.ssh_access \
        -target=module.lambda_scheduler || true
    
    # Destroy completo se ainda houver recursos
    terraform destroy -var-file="environments/${ENVIRONMENT}.tfvars" \
        -auto-approve \
        -parallelism=20 \
        -refresh=false || true

    cd ../../scripts
    
    log_info "Destruição rápida concluída! ⚡"
}

main() {
    [[ "$ENVIRONMENT" =~ ^(dev|stg|prod)$ ]] || { log_error "Ambiente inválido: dev|stg|prod"; exit 1; }
    quick_destroy
}

main