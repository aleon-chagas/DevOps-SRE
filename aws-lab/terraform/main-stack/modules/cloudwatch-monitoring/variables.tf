variable "environment" {
  description = "The deployment environment (e.g., dev, stg, prod)."
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function to monitor."
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
