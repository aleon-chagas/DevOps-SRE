# 1. Output das instâncias com nome e IPs organizados
output "instances" {
  description = "Detalhes das instâncias EC2 com nome, IP público e privado"
  value = {
    for i, name in [for instance in local.selected_config.instances : instance.name] :
    name => {
      instance_id = module.ec2_instances.instance_ids[i]
      public_ip   = module.ec2_instances.instance_public_ips[i]
      private_ip  = module.ec2_instances.instance_private_ips[i]
      ssh_command = "ssh -i ~/.ssh/${var.network.key_name}.pem ubuntu@${module.ec2_instances.instance_public_ips[i]}"
    }
  }
}

# 2. Output das filas SQS
output "sqs_queues" {
  description = "URLs das filas SQS criadas por workspace"
  value = {
    for i, queue in aws_sqs_queue.this :
    queue.name => queue.id
  }
}

# 3. Output do Security Group
output "security_group" {
  description = "Detalhes do Security Group criado automaticamente"
  value = {
    id          = aws_security_group.ssh_access.id
    name        = aws_security_group.ssh_access.name
    description = aws_security_group.ssh_access.description
    allowed_ip  = "${chomp(data.http.my_public_ip.response_body)}/32"
  }
}

# 4. Resumo do ambiente
output "environment_summary" {
  description = "Resumo do ambiente provisionado"
  value = {
    environment    = local.current_environment
    instance_count = length(local.selected_config.instances)
    instance_type  = local.selected_config.default_instance_type
    subnet_id      = local.subnet_mapping[local.current_environment]
    key_pair       = var.network.key_name
  }
}

# 5. Outputs específicos para Ansible
output "k8s_master_public_ip" {
  description = "IP público do K8s master"
  value       = module.ec2_instances.instance_public_ips[0]
}

output "k8s_workers_public_ips" {
  description = "IPs públicos dos workers K8s"
  value       = slice(module.ec2_instances.instance_public_ips, 1, length(module.ec2_instances.instance_public_ips))
}

output "k8s_nodes_public_ips" {
  description = "Todos os IPs públicos (master + workers)"
  value       = module.ec2_instances.instance_public_ips
}