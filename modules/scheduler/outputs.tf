output "lambda_function_name" {
  description = "Cost scheduler Lambda function name."
  value       = aws_lambda_function.cost_scheduler.function_name
}

output "lambda_function_arn" {
  description = "Cost scheduler Lambda ARN."
  value       = aws_lambda_function.cost_scheduler.arn
}

output "stop_schedule_arns" {
  description = "EventBridge Scheduler ARNs for stop rules (null if disabled)."
  value       = { for k, s in aws_scheduler_schedule.stop : k => s.arn }
}

output "start_schedule_arns" {
  description = "EventBridge Scheduler ARNs for start rules (null if disabled)."
  value       = { for k, s in aws_scheduler_schedule.start : k => s.arn }
}

output "timezone" {
  description = "IANA timezone used by schedules."
  value       = var.timezone
}

output "stop_schedules" {
  description = "Configured stop rules (description + cron expression)."
  value = {
    for k, v in local.stop_schedules : k => {
      description = v.description
      expression  = v.expression
      local_time  = v.description != "" ? "${v.description} (${var.timezone})" : v.expression
    }
  }
}

output "start_schedules" {
  description = "Configured start rules (description + cron expression)."
  value = {
    for k, v in local.start_schedules : k => {
      description = v.description
      expression  = v.expression
      local_time  = v.description != "" ? "${v.description} (${var.timezone})" : v.expression
    }
  }
}

output "schedule_summary" {
  description = "Human-readable weekly availability windows in configured timezone."
  value       = "Mon–Fri 06:00–11:00; Sat 18:00–00:00; Sun 06:00–00:00 (${var.timezone})"
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
