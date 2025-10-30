# 1. Log Group é criado automaticamente pelo Lambda
# Não precisamos gerenciá-lo via Terraform

# 2. Alarme de Erros da Lambda
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.lambda_function_name}-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Alarme se a função Lambda ${var.lambda_function_name} tiver erros."
  
  dimensions = {
    FunctionName = var.lambda_function_name
  }

  alarm_actions = [] # Adicionar SNS topic ARN aqui se desejar notificações
  ok_actions      = []

  tags = var.tags
}

# 3. Alarme de Throttling da Lambda
resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${var.lambda_function_name}-throttles"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Alarme se a função Lambda ${var.lambda_function_name} for limitada (throttled)."

  dimensions = {
    FunctionName = var.lambda_function_name
  }

  alarm_actions = [] # Adicionar SNS topic ARN aqui
  ok_actions      = []

  tags = var.tags
}
