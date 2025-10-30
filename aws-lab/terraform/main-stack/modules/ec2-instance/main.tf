resource "aws_instance" "this" {
  count = var.instance_count

  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = var.vpc_security_group_ids
  associate_public_ip_address = var.associate_public_ip
  monitoring                  = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_size = var.disk_size
    volume_type = "gp3"
    encrypted   = true
    delete_on_termination = true
  }

  tags = merge(
    var.tags,
    {
      Name = length(var.instance_names) > 0 ? var.instance_names[count.index] : "${var.instance_name_prefix}-${count.index + 1}"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}