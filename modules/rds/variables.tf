variable "name_prefix" {
  type        = string
  description = "Prefix for resource names (e.g. gamya-couture-prod)."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the DB subnet group (two AZs)."
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Security groups for RDS (PostgreSQL from EC2 SG only)."
}

variable "db_name" {
  type        = string
  description = "Initial PostgreSQL database name."
  default     = "gamya"
}

variable "db_username" {
  type        = string
  description = "Master username (also stored in Parameter Store)."
  default     = "gamya_admin"
}

variable "parameter_store_prefix" {
  type        = string
  description = "SSM Parameter Store path prefix (e.g. /gamya-couture/prod/db)."
}

variable "engine_version" {
  type        = string
  description = "PostgreSQL major/minor version on RDS."
  default     = "16"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class (Graviton)."
  default     = "db.t4g.micro"
}

variable "allocated_storage_gb" {
  type        = number
  description = "Allocated gp3 storage in GB."
  default     = 20
}

variable "storage_type" {
  type    = string
  default = "gp3"
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch Logs retention for RDS PostgreSQL logs."
  default     = 4
}

variable "create_db_secrets_read_policy" {
  type        = bool
  description = "Create IAM policy allowing read of DB username/password parameters."
  default     = true
}

variable "password_rotation_trigger" {
  type        = string
  description = "Change this value to force a new random password (use with care)."
  default     = "1"
  sensitive   = true
}

