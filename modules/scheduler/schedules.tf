resource "aws_lambda_permission" "allow_scheduler_stop" {
  count = var.enabled ? 1 : 0

  statement_id  = "AllowExecutionFromEventBridgeSchedulerStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_scheduler.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn    = aws_scheduler_schedule.stop[0].arn
}

resource "aws_lambda_permission" "allow_scheduler_start" {
  count = var.enabled ? 1 : 0

  statement_id  = "AllowExecutionFromEventBridgeSchedulerStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_scheduler.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn    = aws_scheduler_schedule.start[0].arn
}

resource "aws_scheduler_schedule" "stop" {
  count = var.enabled ? 1 : 0

  name       = "${var.name_prefix}-rds-stop"
  group_name = "default"

  schedule_expression          = var.stop_schedule_expression
  schedule_expression_timezone = var.timezone

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.rds_scheduler.arn
    role_arn = aws_iam_role.scheduler.arn

    input = jsonencode({
      action = "stop"
    })
  }
}

resource "aws_scheduler_schedule" "start" {
  count = var.enabled ? 1 : 0

  name       = "${var.name_prefix}-rds-start"
  group_name = "default"

  schedule_expression          = var.start_schedule_expression
  schedule_expression_timezone = var.timezone

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.rds_scheduler.arn
    role_arn = aws_iam_role.scheduler.arn

    input = jsonencode({
      action = "start"
    })
  }
}
