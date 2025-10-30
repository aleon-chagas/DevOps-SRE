#!/bin/bash
set -euo pipefail

# Script de deploy automatizado da infraestrutura AWS
# Criado por: Aleon Chagas - DevOps/SRE Expert
# Uso: ./scripts/deploy.sh [dev|stg|prod]
# 
# Este script automatiza o deploy completo da infraestrutura AWS:
# 1. Backend remoto (S3 + DynamoDB)
# 2. Network stack (VPC + Subnets)
# 3. Main stack (EC2 + Security Groups + Lambda)
#
# Ambientes disponíveis:
# - dev: 2x t3.micro (Free Tier)
# - stg: 4x t3.small (Staging)
# - prod: 4x t3.medium (Production)

ENVIRONMENT="${1:-dev}"
AWS_REGION="${AWS_REGION:-us-east-1}"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

check_prerequisites() {
    log_step "Verificando pré-requisitos..."

    command -v terraform >/dev/null || { log_error "Terraform não encontrado"; exit 1; }
    command -v aws >/dev/null || { log_error "AWS CLI não encontrado"; exit 1; }
    aws sts get-caller-identity >/dev/null || { log_error "Credenciais AWS inválidas"; exit 1; }

    log_info "Pré-requisitos verificados ✓"
}

deploy_backend() {
    log_step "Deploy backend remoto..."
    cd ../terraform/remote-backend-stack

    terraform init
    terraform plan
    terraform apply -auto-approve

    cd ../../scripts
}

deploy_network() {
    log_step "Deploy network stack..."
    cd ../terraform/network-stack

    BUCKET_NAME=$(cd ../remote-backend-stack && terraform output -raw s3_bucket_name)

    terraform init -backend-config="bucket=${BUCKET_NAME}" \
                   -backend-config="key=network/terraform.tfstate" \
                   -backend-config="region=${AWS_REGION}"

    terraform plan
    terraform apply -auto-approve

    cd ../../scripts
}

deploy_main() {
    log_step "Deploy main stack - ${ENVIRONMENT}"
    cd ../terraform/main-stack

    BUCKET_NAME=$(cd ../remote-backend-stack && terraform output -raw s3_bucket_name)
    sed -i "s/terraform-state-devops-CHANGE-ME/${BUCKET_NAME}/g" backend.tfvars

    terraform init -backend-config=backend.tfvars
    terraform workspace select "${ENVIRONMENT}" 2>/dev/null || terraform workspace new "${ENVIRONMENT}"

    terraform plan -var-file="environments/${ENVIRONMENT}.tfvars"
    
    # Apply com paralelismo otimizado
    terraform apply -var-file="environments/${ENVIRONMENT}.tfvars" \
        -auto-approve \
        -parallelism=10

    terraform output
    
    # Mostrar informações das instâncias
    log_info "Instâncias criadas:"
    aws ec2 describe-instances \
        --filters "Name=tag:Project,Values=devops-aws" "Name=instance-state-name,Values=running,pending" \
        --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value|[0],InstanceId,PublicIpAddress,PrivateIpAddress,State.Name]" \
        --output table || true
    
    cd ../../scripts
}

main() {
    [[ "$ENVIRONMENT" =~ ^(dev|stg|prod)$ ]] || { log_error "Ambiente inválido: dev|stg|prod"; exit 1; }

    log_info "Deploy infraestrutura - Ambiente: ${ENVIRONMENT}"

    check_prerequisites
    deploy_backend
    deploy_network
    deploy_main

    log_info "Deploy finalizado! 🚀"
}

main