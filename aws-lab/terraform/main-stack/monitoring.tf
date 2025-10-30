module "cloudwatch_monitoring" {
  source = "./modules/cloudwatch-monitoring"

  environment          = local.current_environment
  aws_region           = "us-east-1"
  lambda_function_name = module.lambda_scheduler.function_name
  tags                 = var.tags
}
