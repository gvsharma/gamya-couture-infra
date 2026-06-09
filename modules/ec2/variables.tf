variable "name_prefix" {
  type        = string
  description = "Prefix for resource names (e.g. gamya-couture-prod)."
}

variable "environment" {
  type        = string
  description = "Environment label used in logs and paths."
}

variable "subnet_id" {
  type        = string
  description = "Public subnet ID for the application instance."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups attached to the instance (app SG)."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type (ARM Graviton)."
  default     = "t4g.small"
}

variable "ami_id" {
  type        = string
  description = "Optional AMI override. Defaults to latest Amazon Linux 2023 ARM64."
  default     = null
}

variable "key_name" {
  type        = string
  description = "Optional EC2 key pair name for SSH."
  default     = null
}

variable "root_volume_size_gb" {
  type        = number
  description = "Root EBS volume size in GB (gp3)."
  default     = 30
}

variable "api_port" {
  type        = number
  description = "Spring Boot listen port behind nginx."
  default     = 8080
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch Logs retention for application log groups."
  default     = 4
}

variable "additional_iam_policy_arns" {
  type        = list(string)
  description = "Extra IAM policy ARNs (e.g. S3 media bucket access)."
  default     = []
}
