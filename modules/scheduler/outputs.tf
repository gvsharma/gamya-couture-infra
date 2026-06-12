output "lambda_function_name" {
  description = "Cost scheduler Lambda function name."
  value       = aws_lambda_function.cost_scheduler.function_name
}

output "lambda_function_arn" {
  description = "Cost scheduler Lambda ARN."
  value       = aws_lambda_function.cost_scheduler.arn
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
  value       = "09:00 daily (${var.timezone})"
}

output "schedule_ec2" {
  description = "Whether EC2 stop/start is configured."
  value       = local.schedule_ec2
}

output "schedule_rds" {
  description = "Whether RDS stop/start is configured."
  value       = local.schedule_rds
}

output "cloudwatch_log_group_name" {
  description = "Lambda log group name."
  value       = aws_cloudwatch_log_group.lambda.name
}
