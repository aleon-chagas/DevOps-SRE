# Configurações do ambiente de produção
ec2_environment = "prod"

# Habilitar IP público para SSH
associate_public_ip = true

# Tags padrão para todos os recursos
tags = {
  Project     = "devops"
  Schedule    = "stop-daily-18h"
  Environment = "prod"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
  CostCenter  = "production"
}

# Configurações de rede - subnets e security groups são criados automaticamente
network = {
  key_name = "devops2025"
}