#!/bin/bash

# Validar ambiente
ENV=${1:-dev}  # usa 'dev' como padrão se nenhum ambiente for especificado
if [[ ! "$ENV" =~ ^(dev|stg|prod)$ ]]; then
    echo "Ambiente inválido. Use: dev, stg ou prod"
    exit 1
fi

# Selecionar ou criar workspace
terraform workspace select "$ENV" || terraform workspace new "$ENV"

# Executar comando terraform (todos argumentos após o ambiente)
shift
if [ $# -gt 0 ]; then
    terraform "$@"
fi