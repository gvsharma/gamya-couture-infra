variable "name_prefix" {
  type        = string
  description = "Prefix for resource names (e.g. gamya-couture-prod)."
}

variable "db_instance_identifier" {
  type        = string
  description = "RDS DB instance identifier to stop/start."
}

variable "db_instance_arn" {
  type        = string
  description = "RDS DB instance ARN (scopes IAM permissions)."
}

variable "timezone" {
  type        = string
  description = "IANA timezone for schedules (IST = Asia/Kolkata)."
  default     = "Asia/Kolkata"
}

variable "stop_schedule_expression" {
  type        = string
  description = "EventBridge Scheduler cron for daily stop (12:00 AM in timezone)."
  default     = "cron(0 0 * * ? *)"
}

variable "start_schedule_expression" {
  type        = string
  description = "EventBridge Scheduler cron for daily start (7:00 AM in timezone)."
  default     = "cron(0 7 * * ? *)"
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch Logs retention for the Lambda function."
  default     = 4
}

variable "lambda_timeout_seconds" {
  type        = number
  default     = 60
}

variable "lambda_memory_mb" {
  type        = number
  default     = 128
}

variable "enabled" {
  type        = bool
  description = "Create EventBridge schedules (set false to disable without removing Lambda)."
  default     = true
}
