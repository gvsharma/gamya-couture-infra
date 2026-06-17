variable "name_prefix" {
  type        = string
  description = "Prefix for resource names (e.g. gamya-couture-dev)."
}

variable "db_instance_identifier" {
  type        = string
  description = "RDS DB instance identifier to stop/start. Leave empty to skip RDS."
  default     = ""
}

variable "ec2_instance_id" {
  type        = string
  description = "EC2 instance ID to stop/start."
  default     = ""
}

variable "schedule_rds" {
  type        = bool
  description = "Include RDS in stop/start schedule and IAM."
  default     = true
}

variable "schedule_ec2" {
  type        = bool
  description = "Include EC2 in stop/start schedule and IAM."
  default     = true
}

variable "timezone" {
  type        = string
  description = "IANA timezone for schedules (IST = Asia/Kolkata)."
  default     = "Asia/Kolkata"
}

variable "stop_schedules" {
  type = map(object({
    expression  = string
    description = optional(string, "")
  }))
  description = "EventBridge Scheduler stop rules (key = schedule name). Empty map uses built-in Mon–Sun IST defaults."
  default     = {}
}

variable "start_schedules" {
  type = map(object({
    expression  = string
    description = optional(string, "")
  }))
  description = "EventBridge Scheduler start rules (key = schedule name). Empty map uses built-in Mon–Sun IST defaults."
  default     = {}
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
