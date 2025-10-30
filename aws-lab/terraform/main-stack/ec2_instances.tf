# 1. Data Source para encontrar a AMI do Ubuntu 22.04
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS Account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. Lógica para Seleção de Ambiente (Utiliza o Workspace)
# Este locals permanece na stack raiz para decidir QUAL configuração passar para o módulo.
locals {
  current_environment = terraform.workspace == "default" ? "dev" : terraform.workspace
  selected_config     = var.environment_config[local.current_environment]
}

# 3. Chama o módulo de instância EC2
module "ec2_instances" {
  source = "./modules/ec2-instance"

  # A contagem de instâncias agora é controlada pela configuração do ambiente
  instance_count = length(local.selected_config.instances)
  instance_names = [for instance in local.selected_config.instances : instance.name]

  # Passando os dados para o módulo
  ami_id          = data.aws_ami.ubuntu_2204.id
  instance_type   = local.selected_config.default_instance_type
  disk_size       = local.selected_config.default_disk_size

  # Configurações de rede - usando data sources dinâmicos
  subnet_id              = local.subnet_mapping[local.current_environment]
  key_name               = var.network.key_name
  vpc_security_group_ids = [aws_security_group.ssh_access.id]
  associate_public_ip    = var.associate_public_ip

  # Tags
  tags = merge(
    var.tags,
    {
      Environment = local.current_environment
    }
  )
}
