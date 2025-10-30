variable "authentication" {
  type = object({
    assume_role_arn = string
    region          = string
  })

  default = {
    assume_role_arn = "arn:aws:iam::867386273093:role/CursoDevOpsAWSRole"
    region          = "us-east-1"
  }
}

variable "bucket_name" {
  description = "The name of the S3 bucket for the Terraform state."
  type        = string
  default     = "devops-sre-aleon"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for the Terraform state lock."
  type        = string
  default     = "devops-aws-remote-backend-locks"
}
