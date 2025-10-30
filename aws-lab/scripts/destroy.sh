#!/bin/bash
set -euo pipefail

# Script para destruir infraestrutura
# Uso: ./scripts/destroy.sh [dev|stg|prod]

ENVIRONMENT="${1:-dev}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

force_stop_instances() {
    log_warn "Forçando parada das instâncias EC2..."
    
    # Obter IDs das instâncias com tag do projeto
    INSTANCE_IDS=$(aws ec2 describe-instances \
        --filters "Name=tag:Project,Values=devops-aws" "Name=instance-state-name,Values=running,pending,stopping" \
        --query "Reservations[*].Instances[*].InstanceId" \
        --output text 2>/dev/null || echo "")
    
    if [[ -n "$INSTANCE_IDS" ]]; then
        log_info "Parando instâncias: $INSTANCE_IDS"
        aws ec2 stop-instances --instance-ids $INSTANCE_IDS --force || true
        
        # Aguardar parada
        log_info "Aguardando instâncias pararem..."
        aws ec2 wait instance-stopped --instance-ids $INSTANCE_IDS --cli-read-timeout 300 || true
    fi
}

destroy_main() {
    log_warn "Destruindo main stack - ${ENVIRONMENT}"
    cd ../terraform/main-stack

    # Forçar parada das instâncias primeiro
    force_stop_instances

    terraform init -backend-config=backend.tfvars
    
    # Selecionar workspace ou usar default se for dev
    if [[ "${ENVIRONMENT}" == "dev" ]]; then
        terraform workspace select default 2>/dev/null || true
    else
        terraform workspace select "${ENVIRONMENT}" 2>/dev/null || {
            log_error "Workspace ${ENVIRONMENT} não existe"
            cd ../../scripts
            return 1
        }
    fi
    
    # Destroy com paralelismo e timeout otimizado
    terraform destroy -var-file="environments/${ENVIRONMENT}.tfvars" \
        -auto-approve \
        -parallelism=10 \
        -refresh=false

    cd ../../scripts
}

destroy_network() {
    log_warn "Destruindo network stack..."
    cd ../terraform/network-stack

    terraform destroy -auto-approve -parallelism=10

    cd ../../scripts
}

destroy_backend() {
    log_warn "Destruindo backend remoto..."
    cd ../terraform/remote-backend-stack

    # Limpar bucket S3 primeiro
    BUCKET_NAME=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")
    if [[ -n "$BUCKET_NAME" ]]; then
        log_info "Limpando bucket S3: $BUCKET_NAME"
        aws s3 rm "s3://${BUCKET_NAME}" --recursive || true
        
        # Forçar remoção de versões se houver
        aws s3api delete-bucket --bucket "$BUCKET_NAME" --region us-east-1 || true
    fi

    terraform destroy -auto-approve -parallelism=10

    cd ../../scripts
}

main() {
    [[ "$ENVIRONMENT" =~ ^(dev|stg|prod)$ ]] || { log_error "Ambiente inválido: dev|stg|prod"; exit 1; }

    log_error "⚠️  ATENÇÃO: Isso irá DESTRUIR toda a infraestrutura do ambiente ${ENVIRONMENT}!"
    read -p "Tem certeza? Digite 'DESTROY' para confirmar: " confirm

    if [[ "$confirm" != "DESTROY" ]]; then
        log_info "Operação cancelada"
        exit 0
    fi

    destroy_main

    read -p "Destruir também network e backend? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        destroy_network
        destroy_backend
    fi

    log_info "Destruição concluída"
}

main