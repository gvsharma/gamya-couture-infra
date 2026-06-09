data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/.build/scheduler.zip"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.name_prefix}-cost-scheduler"
  retention_in_days = var.log_retention_days

  tags = {
    Name            = "${var.name_prefix}-cost-scheduler-logs"
    ResourcePurpose = "cost-scheduler-logs"
  }
}

resource "aws_lambda_function" "cost_scheduler" {
  function_name = "${var.name_prefix}-cost-scheduler"
  description   = "Daily stop/start EC2 and RDS for cost optimization (IST schedule)."
  role          = aws_iam_role.lambda.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"
  timeout       = var.lambda_timeout_seconds
  memory_size   = var.lambda_memory_mb

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      EC2_INSTANCE_ID           = var.ec2_instance_id
      DB_INSTANCE_IDENTIFIER    = var.db_instance_identifier
      RDS_WAIT_MAX_SECONDS      = tostring(var.rds_wait_max_seconds)
      RDS_POLL_INTERVAL_SECONDS = tostring(var.rds_poll_interval_seconds)
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy.lambda_logging,
  ]

  tags = {
    Name            = "${var.name_prefix}-cost-scheduler"
    ResourcePurpose = "cost-scheduler-lambda"
  }
}
