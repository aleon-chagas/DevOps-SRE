variable "instance_name_prefix" {
  description = "The prefix for the instance name."
  type        = string
  default     = "k8s-node"
}

variable "instance_count" {
  description = "The number of instances to create."
  type        = number

  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "ami_id" {
  description = "The ID of the AMI to use for the instances."
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]{8,17}$", var.ami_id))
    error_message = "AMI ID must be a valid format (ami-xxxxxxxx)."
  }
}

variable "instance_type" {
  description = "The type of instance to create."
  type        = string
}

variable "disk_size" {
  description = "The size of the root block device in GB."
  type        = number
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instances in."
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for the instances."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with the instances."
  type        = list(string)
}

variable "associate_public_ip" {
  description = "Whether to associate a public IP address with the instance."
  type        = bool
  default     = false
}

variable "instance_names" {
  description = "List of specific names for each instance."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
  default     = {}
}
