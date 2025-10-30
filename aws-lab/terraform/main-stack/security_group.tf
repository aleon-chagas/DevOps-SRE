# Data source para obter o IP público atual
data "http" "my_public_ip" {
  url = "https://ipv4.icanhazip.com"
}

# Data source para obter a VPC padrão ou a VPC criada pelo network-stack
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["vpc-principal"]
  }
}

# Security Group completo para o lab DevOps/SRE
resource "aws_security_group" "ssh_access" {
  name_prefix = "devops-lab-${local.current_environment}-"
  description = "Security group for DevOps/SRE lab - SSH, K8s, Apps and inter-instance communication"
  vpc_id      = data.aws_vpc.main.id

  # SSH access from my public IP
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_public_ip.response_body)}/32"]
  }

  # Weather App (NodePort)
  ingress {
    description = "Weather App NodePort"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_public_ip.response_body)}/32"]
  }

  # Grafana (NodePort)
  ingress {
    description = "Grafana NodePort"
    from_port   = 30300
    to_port     = 30300
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_public_ip.response_body)}/32"]
  }

  # Prometheus (NodePort)
  ingress {
    description = "Prometheus NodePort"
    from_port   = 30900
    to_port     = 30900
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_public_ip.response_body)}/32"]
  }

  # Kubernetes API Server
  ingress {
    description = "Kubernetes API Server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_public_ip.response_body)}/32"]
  }

  # Weather App Backend (internal)
  ingress {
    description = "Weather API Backend"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_public_ip.response_body)}/32"]
  }

  # Weather App Frontend (internal)
  ingress {
    description = "Weather Frontend"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_public_ip.response_body)}/32"]
  }

  # Redis (internal)
  ingress {
    description = "Redis Cache"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_public_ip.response_body)}/32"]
  }

  # Inter-instance communication (all traffic between instances)
  ingress {
    description = "Inter-instance communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Inter-instance communication (UDP)
  ingress {
    description = "Inter-instance communication UDP"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    self        = true
  }

  # ICMP for ping between instances
  ingress {
    description = "ICMP ping between instances"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    self        = true
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "devops-lab-sg-${local.current_environment}"
      Environment = local.current_environment
      Purpose     = "DevOps/SRE Lab Security Group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}