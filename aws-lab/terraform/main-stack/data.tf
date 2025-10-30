# Data sources para buscar subnets automaticamente por nome
# Isso elimina a necessidade de atualizar IDs manualmente

data "aws_subnet" "dev_public" {
  filter {
    name   = "tag:Name"
    values = ["subnet-dev-public"]
  }
}

data "aws_subnet" "stg_public" {
  filter {
    name   = "tag:Name"
    values = ["subnet-stg-public"]
  }
}

data "aws_subnet" "prod_public" {
  filter {
    name   = "tag:Name"
    values = ["subnet-prod-public"]
  }
}

# Mapeamento dinâmico das subnets
locals {
  subnet_mapping = {
    dev  = data.aws_subnet.dev_public.id
    stg  = data.aws_subnet.stg_public.id
    prod = data.aws_subnet.prod_public.id
  }
}