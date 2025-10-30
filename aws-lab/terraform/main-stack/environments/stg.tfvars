# Configurações do ambiente de staging
ec2_environment = "stg"

# Habilitar IP público para SSH
associate_public_ip = true

# Tags padrão para todos os recursos
tags = {
  Project     = "devops"
  Schedule    = "stop-daily-18h"
  Environment = "stg"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
  CostCenter  = "staging"
}

# Configurações de rede - subnets e security groups são criados automaticamente
network = {
  key_name = "devops2025"
}