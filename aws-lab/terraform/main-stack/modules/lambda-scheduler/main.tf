# 1. Empacota o código Python em um arquivo ZIP
data "archive_file" "scheduler_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/scheduler.py"
  output_path = "${path.module}/lambda/scheduler.zip"
}

# 2. IAM Role para a Lambda Function
resource "aws_iam_role" "scheduler_role" {
  name = "lambda-ec2-scheduler-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

# 2.1. Policy: Permissão para LOGS e EC2
resource "aws_iam_policy" "scheduler_policy" {
  name        = "lambda-ec2-scheduler-policy-${var.environment}"
  description = "Permite à Lambda desligar EC2s e escrever logs."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:StopInstances"
        ],
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# 2.2. Associa a policy à Role
resource "aws_iam_role_policy_attachment" "scheduler_attach" {
  role       = aws_iam_role.scheduler_role.name
  policy_arn = aws_iam_policy.scheduler_policy.arn
}
# 3. Lambda Function
resource "aws_lambda_function" "ec2_scheduler" {
  filename         = data.archive_file.scheduler_zip.output_path
  function_name    = "EC2Scheduler-${var.environment}"
  role             = aws_iam_role.scheduler_role.arn
  handler          = "scheduler.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.scheduler_zip.output_base64sha256
  timeout          = 30

  environment {
    variables = {
      SCHEDULE_TAG_KEY   = "Schedule"
      SCHEDULE_TAG_VALUE = var.schedule_tag_value
      TARGET_HOUR        = var.target_hour
      TIMEZONE           = var.timezone
      DRY_RUN            = "false"
    }
  }

  tags = var.tags
}

# 4. EventBridge Rule (O Agendador CRON)
resource "aws_cloudwatch_event_rule" "stop_rule" {
  name        = "stop-ec2-daily-18h-${var.environment}"
  description = "Desliga as instâncias com a Tag Schedule=${var.schedule_tag_value} às ${var.target_hour}:00."

  # Executa às 21:00 UTC (18:00 BRT)
  schedule_expression = "cron(0 21 * * ? *)"

  tags = var.tags
}

# 5. EventBridge Target (Aponta a regra para a função Lambda)
resource "aws_cloudwatch_event_target" "scheduler_target" {
  rule = aws_cloudwatch_event_rule.stop_rule.name
  arn  = aws_lambda_function.ec2_scheduler.arn
}

# 6. Permissão para o EventBridge invocar a Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_rule.arn
}