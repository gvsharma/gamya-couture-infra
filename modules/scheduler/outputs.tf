output "lambda_function_name" {
  description = "RDS scheduler Lambda function name."
  value       = aws_lambda_function.rds_scheduler.function_name
}

output "lambda_function_arn" {
  description = "RDS scheduler Lambda ARN."
  value       = aws_lambda_function.rds_scheduler.arn
}

output "stop_schedule_arn" {
  description = "EventBridge Scheduler ARN for daily stop (null if disabled)."
  value       = try(aws_scheduler_schedule.stop[0].arn, null)
}

output "start_schedule_arn" {
  description = "EventBridge Scheduler ARN for daily start (null if disabled)."
  value       = try(aws_scheduler_schedule.start[0].arn, null)
}

output "timezone" {
  description = "IANA timezone used by schedules."
  value       = var.timezone
}

output "stop_schedule_local_time" {
  description = "Human-readable stop time in configured timezone."
  value       = "00:00 daily (${var.timezone})"
}

output "start_schedule_local_time" {
  description = "Human-readable start time in configured timezone."
  value       = "07:00 daily (${var.timezone})"
}

output "cloudwatch_log_group_name" {
  description = "Lambda log group name."
  value       = aws_cloudwatch_log_group.lambda.name
}
