# ------------------------------------------------------------------------------
# General
# ------------------------------------------------------------------------------

variable "aws_region" {
  type        = string
  description = "Primary AWS region."
  default     = "ap-south-1"
}

variable "environment" {
  type        = string
  description = "Environment name."
  default     = "prod"
}

variable "project" {
  type        = string
  description = "Project slug used in resource names."
  default     = "gamya-couture"
}

variable "owner" {
  type        = string
  default     = "platform"
}

variable "cost_center" {
  type        = string
  default     = "mvp"
}

# ------------------------------------------------------------------------------
# Network (Phase 2+)
# ------------------------------------------------------------------------------

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block."
  default     = "10.0.0.0/16"
}

# ------------------------------------------------------------------------------
# Security (Phase 3+)
# ------------------------------------------------------------------------------

variable "admin_cidr" {
  type        = string
  description = "Your public IP in CIDR notation for SSH (e.g. 203.0.113.10/32)."
}

# ------------------------------------------------------------------------------
# DNS (Phase 9+)
# ------------------------------------------------------------------------------

variable "domain_name" {
  type        = string
  description = "Root domain (e.g. gamyacouture.com). Leave empty to skip Route53/ACM."
  default     = "gamyacouture.com"
}

variable "api_subdomain" {
  type        = string
  description = "API hostname prefix."
  default     = "api"
}

variable "www_subdomain" {
  type        = string
  description = "WWW / site hostname prefix."
  default     = "www"
}

variable "admin_subdomain" {
  type        = string
  description = "Admin / CRM hostname prefix."
  default     = "admin"
}

# ------------------------------------------------------------------------------
# RDS (Phase 4+)
# ------------------------------------------------------------------------------

variable "db_name" {
  type        = string
  default     = "gamya"
}

variable "db_username" {
  type        = string
  default     = "gamya_admin"
}

variable "enable_rds_schedule" {
  type        = bool
  description = "Stop RDS 00:00–07:00 IST daily."
  default     = true
}

# ------------------------------------------------------------------------------
# EC2 (Phase 6+)
# ------------------------------------------------------------------------------

variable "ec2_instance_type" {
  type        = string
  description = "ARM Graviton instance for Docker / Spring Boot."
  default     = "t4g.small"
}

variable "ec2_key_name" {
  type        = string
  description = "Optional EC2 key pair for SSH (SSM preferred)."
  default     = null
}
