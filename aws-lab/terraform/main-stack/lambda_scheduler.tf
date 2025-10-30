module "lambda_scheduler" {
  source = "./modules/lambda-scheduler"

  environment = var.environment
  aws_region  = "us-east-1"
  target_hour = var.target_hour
  timezone    = var.timezone
  tags        = var.tags
}
