resource "aws_lambda_permission" "allow_scheduler_stop" {
  for_each = var.enabled ? local.stop_schedules : {}

  statement_id  = "AllowExecutionFromEventBridgeSchedulerStop${replace(title(each.key), "_", "")}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_scheduler.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn    = aws_scheduler_schedule.stop[each.key].arn
}

resource "aws_lambda_permission" "allow_scheduler_start" {
  for_each = var.enabled ? local.start_schedules : {}

  statement_id  = "AllowExecutionFromEventBridgeSchedulerStart${replace(title(each.key), "_", "")}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_scheduler.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn    = aws_scheduler_schedule.start[each.key].arn
}

resource "aws_scheduler_schedule" "stop" {
  for_each = var.enabled ? local.stop_schedules : {}

  name       = "${var.name_prefix}-compute-stop-${each.key}"
  group_name = "default"

  schedule_expression          = each.value.expression
  schedule_expression_timezone = var.timezone

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.cost_scheduler.arn
    role_arn = aws_iam_role.scheduler.arn

    input = jsonencode({
      action = "stop"
    })
  }
}

resource "aws_scheduler_schedule" "start" {
  for_each = var.enabled ? local.start_schedules : {}

  name       = "${var.name_prefix}-compute-start-${each.key}"
  group_name = "default"

  schedule_expression          = each.value.expression
  schedule_expression_timezone = var.timezone

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.cost_scheduler.arn
    role_arn = aws_iam_role.scheduler.arn

    input = jsonencode({
      action = "start"
    })
  }
}
