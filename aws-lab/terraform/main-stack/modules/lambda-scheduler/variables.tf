variable "environment" {
  description = "The deployment environment (e.g., dev, stg, prod)."
  type        = string
}

variable "aws_region" {
  description = "The AWS region for the resources."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
  default     = {}
}

variable "schedule_tag_value" {
  description = "The value of the tag used to identify instances to be stopped."
  type        = string
  default     = "stop-daily-18h"
}

variable "target_hour" {
  description = "The hour (in the specified timezone) to stop the instances."
  type        = string
  default     = "18"
}

variable "timezone" {
  description = "The timezone to use for the scheduler."
  type        = string
  default     = "America/Sao_Paulo"
}
