output "function_name" {
  description = "The name of the Lambda function."
  value       = aws_lambda_function.ec2_scheduler.function_name
}

output "function_arn" {
  description = "The ARN of the Lambda function."
  value       = aws_lambda_function.ec2_scheduler.arn
}
