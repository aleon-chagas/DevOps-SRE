locals {
  # Tags comuns para todos os recursos
  common_tags = merge(var.tags, {
    Environment = terraform.workspace == "default" ? "dev" : terraform.workspace
    Owner       = "DevOps-Team"
  })
}