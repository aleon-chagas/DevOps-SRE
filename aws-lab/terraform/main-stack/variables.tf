

variable "tags" {
  type        = map(string)
  description = "Default tags to be applied to all resources"

  default = {
    Project   = "devops-aws"
    Schedule  = "stop-daily-18h"
    Terraform = "true"
  }

  validation {
    condition     = can(var.tags["Project"]) && can(var.tags["Schedule"])
    error_message = "The tags map must contain at least 'Project' and 'Schedule' keys."
  }
}

variable "ec2_environment" {
  type        = string
  description = "The Environment tag specific to EC2 instances (e.g. dev, stg, prod)."

  validation {
    condition     = contains(["dev", "stg", "prod"], var.ec2_environment)
    error_message = "Environment must be one of: dev, stg, prod."
  }
}

variable "associate_public_ip" {
  type        = bool
  description = "Whether to associate a public IP address with the instance."
  default     = false
}

variable "queue" {
  type = list(object({
    name                      = string
    delay_seconds             = number
    max_message_size          = number
    message_retention_seconds = number
    receive_wait_time_seconds = number
  }))
  default = [{
    name                      = "devops-aws-queue-01"
    delay_seconds             = 90
    max_message_size          = 2048
    message_retention_seconds = 86400
    receive_wait_time_seconds = 10
    }, {
    name                      = "devops-aws-queue-02"
    delay_seconds             = 90
    max_message_size          = 2048
    message_retention_seconds = 86400
    receive_wait_time_seconds = 10
  }]
}

variable "environment_config" {
  type = map(object({
    default_instance_type = string
    default_disk_size     = number
    instances = list(object({
      name = string
    }))
  }))
  default = {
    "dev" = {
      default_instance_type = "t2.small"
      default_disk_size     = 20
      instances = [
        { name = "k8s-master" }, { name = "k8s-worker-1" }, { name = "k8s-worker-2" }, { name = "k8s-worker-3" }
      ]
    }
    "stg" = {
      default_instance_type = "t2.medium"
      default_disk_size     = 30
      instances = [
        { name = "k8s-master" }, { name = "k8s-worker-1" }, { name = "k8s-worker-2" }, { name = "k8s-worker-3" }
      ]
    }
    "prod" = {
      default_instance_type = "t2.large"
      default_disk_size     = 50
      instances = [
        { name = "k8s-master" }, { name = "k8s-worker-1" }, { name = "k8s-worker-2" }, { name = "k8s-worker-3" }
      ]
    }
  }
}

variable "network" {
  type = object({
    key_name = string
  })

  description = "Network configuration - subnets e security groups são criados automaticamente"

  default = {
    key_name = "devops2025"
  }
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, stg, prod)."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "instance_count" {
  type        = number
  description = "Number of EC2 instances to create"
  default     = 1
}

variable "lambda_schedule_expression" {
  type        = string
  description = "Cron expression for Lambda scheduler"
  default     = "cron(0 18 * * ? *)"
}

variable "target_hour" {
  type        = string
  description = "The hour (in the specified timezone) to stop the instances."
  default     = "18"
}

variable "timezone" {
  type        = string
  description = "The timezone to use for the scheduler."
  default     = "America/Sao_Paulo"
}

variable "enable_detailed_monitoring" {
  type        = bool
  description = "Enable detailed monitoring for EC2 instances"
  default     = false
}

variable "cloudwatch_log_retention" {
  type        = number
  description = "CloudWatch log retention in days"
  default     = 14
}