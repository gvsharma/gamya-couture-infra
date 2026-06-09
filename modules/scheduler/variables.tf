variable "name_prefix" {
  type        = string
  description = "Prefix for resource names (e.g. gamya-couture-dev)."
}

variable "db_instance_identifier" {
  type        = string
  description = "RDS DB instance identifier to stop/start. Leave empty to skip RDS."
  default     = ""
}

variable "db_instance_arn" {
  type        = string
  description = "RDS DB instance ARN (scopes IAM). Required when db_instance_identifier is set."
  default     = ""
}

variable "ec2_instance_id" {
  type        = string
  description = "EC2 instance ID to stop/start. Leave empty to skip EC2."
  default     = ""
}

variable "ec2_instance_arn" {
  type        = string
  description = "EC2 instance ARN (scopes IAM). Required when ec2_instance_id is set."
  default     = ""
}

variable "timezone" {
  type        = string
  description = "IANA timezone for schedules (IST = Asia/Kolkata)."
  default     = "Asia/Kolkata"
}

variable "stop_schedule_expression" {
  type        = string
  description = "EventBridge Scheduler cron for daily stop (12:00 AM IST default)."
  default     = "cron(0 0 * * ? *)"
}

variable "start_schedule_expression" {
  type        = string
  description = "EventBridge Scheduler cron for daily start (9:00 AM IST default)."
  default     = "cron(0 9 * * ? *)"
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch Logs retention for the Lambda function."
  default     = 3
}

variable "lambda_timeout_seconds" {
  type        = number
  description = "Lambda timeout (must cover RDS start + poll window)."
  default     = 120
}

variable "lambda_memory_mb" {
  type    = number
  default = 128
}

variable "rds_wait_max_seconds" {
  type        = number
  description = "Max seconds to wait for RDS to become available after start."
  default     = 600
}

variable "rds_poll_interval_seconds" {
  type        = number
  description = "Seconds between RDS availability polls after start."
  default     = 15
}

variable "enabled" {
  type        = bool
  description = "Create EventBridge schedules (set false to disable without removing Lambda)."
  default     = true
}
