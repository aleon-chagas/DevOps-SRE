output "instance_ids" {
  description = "A list of the IDs of the created EC2 instances."
  value       = aws_instance.this[*].id
}

output "instance_public_ips" {
  description = "A list of the public IP addresses of the created EC2 instances."
  value       = aws_instance.this[*].public_ip
}

output "instance_private_ips" {
  description = "A list of the private IP addresses of the created EC2 instances."
  value       = aws_instance.this[*].private_ip
}
