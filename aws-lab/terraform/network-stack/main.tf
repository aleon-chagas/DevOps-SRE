# network-stack/main.tf

# 1. Define a VPC principal
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(local.common_tags, {
    Name        = "vpc-principal"
    Environment = "multi-env"
  })
}

# 2. Define locals para as subnets publicas e privadas
locals {
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  public_subnets = {
    "dev-public" = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    },
    "stg-public" = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
    },
    "prod-public" = {
      cidr_block        = "10.0.3.0/24"
      availability_zone = "us-east-1c"
    }
  }

  private_subnets = {
    "dev-private" = {
      cidr_block        = "10.0.101.0/24"
      availability_zone = "us-east-1a"
      nat_gateway_key   = "dev-public"
    },
    "stg-private" = {
      cidr_block        = "10.0.102.0/24"
      availability_zone = "us-east-1b"
      nat_gateway_key   = "stg-public"
    },
    "prod-private" = {
      cidr_block        = "10.0.103.0/24"
      availability_zone = "us-east-1c"
      nat_gateway_key   = "prod-public"
    }
  }

  common_tags = {
    Project   = "devops"
    ManagedBy = "terraform"
  }

  # Função para extrair ambiente do nome da subnet
  get_environment = {
    for key in keys(merge(local.public_subnets, local.private_subnets)) :
    key => split("-", key)[0]
  }
}

# 3. Cria as Subnets Publicas
resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true # Importante para subnets publicas

  tags = merge(local.common_tags, {
    Name        = "subnet-${each.key}"
    Tier        = "Public"
    Type        = "public"
    Environment = local.get_environment[each.key] #extrai automaticamente o prefixo do ambiente
  })
}

# 4. Cria as Subnets Privadas
resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = merge(local.common_tags, {
    Name        = "subnet-${each.key}"
    Tier        = "Private"
    Type        = "private"
    Environment = local.get_environment[each.key]
  })
}

# 5. Cria o Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.common_tags, {
    Name        = "igw-main"
    Environment = "multi-env"
  })
}

# 6. Cria a Tabela de Roteamento Publica
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name        = "rt-public"
    Environment = "multi-env"
  })
}

# 7. Associa as Subnets Publicas com a Tabela de Roteamento Publica
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# 8. Cria Elastic IPs e NAT Gateways para alta disponibilidade
resource "aws_eip" "nat" {
  for_each = local.public_subnets

  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = merge(local.common_tags, {
    Name        = "eip-nat-${each.key}"
    Environment = local.get_environment[each.key]
  })
}

resource "aws_nat_gateway" "nat" {
  for_each = local.public_subnets

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  depends_on    = [aws_internet_gateway.igw]

  tags = merge(local.common_tags, {
    Name        = "nat-gw-${each.key}"
    Environment = local.get_environment[each.key]
  })
}

# 9. Cria Tabelas de Roteamento Privadas (uma por AZ)
resource "aws_route_table" "private" {
  for_each = local.private_subnets

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.value.nat_gateway_key].id
  }

  tags = merge(local.common_tags, {
    Name        = "rt-private-${each.key}"
    Environment = local.get_environment[each.key]
  })
}

# 10. Associa as Subnets Privadas com suas respectivas Tabelas de Roteamento
resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# 11. Exporta os IDs da VPC e das subnets para outras stacks usarem
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids_map" {
  description = "Mapa com os IDs das subnets publicas criadas"
  value       = { for key, subnet in aws_subnet.public : key => subnet.id }
}

output "private_subnet_ids_map" {
  description = "Mapa com os IDs das subnets privadas criadas"
  value       = { for key, subnet in aws_subnet.private : key => subnet.id }
}