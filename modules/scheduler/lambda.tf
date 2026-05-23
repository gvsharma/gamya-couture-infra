data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/.build/scheduler.zip"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.name_prefix}-rds-scheduler"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.name_prefix}-rds-scheduler-logs"
  }
}

resource "aws_lambda_function" "rds_scheduler" {
  function_name = "${var.name_prefix}-rds-scheduler"
  description   = "Stop/start RDS instance on a daily cost-saving schedule."
  role          = aws_iam_role.lambda.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"
  timeout       = var.lambda_timeout_seconds
  memory_size   = var.lambda_memory_mb

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      DB_INSTANCE_IDENTIFIER = var.db_instance_identifier
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy.lambda_logging,
  ]

  tags = {
    Name = "${var.name_prefix}-rds-scheduler"
  }
}
