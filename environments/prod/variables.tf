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
  description = "Owner tag for all resources."
  default     = "Venkat"
}

variable "cost_optimization" {
  type        = string
  description = "CostOptimization tag value."
  default     = "enabled"
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
  description = "Your public IP in CIDR notation for SSH when enable_ssh is true (must be /32)."
  default     = "127.0.0.1/32"
}

variable "enable_ssh" {
  type        = bool
  description = "Allow SSH to EC2 from admin_cidr. Prefer false; use SSM Session Manager."
  default     = false
}

variable "restrict_web_ingress_to_cloudfront" {
  type        = bool
  description = "Restrict EC2 HTTP/HTTPS to CloudFront origin-facing IPs only."
  default     = true
}

variable "web_ingress_cidr_blocks" {
  type        = list(string)
  description = "HTTP/HTTPS CIDR allowlist when CloudFront restriction is disabled."
  default     = ["0.0.0.0/0"]
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
  type    = string
  default = "gamya"
}

variable "db_username" {
  type    = string
  default = "gamya_admin"
}

variable "enable_cost_schedule" {
  type        = bool
  description = "Enable EC2+RDS stop/start schedules (Mon–Fri 06:00–11:00; Sat 18:00–00:00; Sun 06:00–00:00 IST by default)."
  default     = true
}

variable "schedule_timezone" {
  type        = string
  description = "IANA timezone for cost scheduler."
  default     = "Asia/Kolkata"
}

variable "schedule_stop_overrides" {
  type = map(object({
    expression  = string
    description = optional(string, "")
  }))
  description = "Optional stop rules (key = schedule name). Empty map uses module defaults."
  default     = {}
}

variable "schedule_start_overrides" {
  type = map(object({
    expression  = string
    description = optional(string, "")
  }))
  description = "Optional start rules (key = schedule name). Empty map uses module defaults."
  default     = {}
}

# ------------------------------------------------------------------------------
# EC2 (Phase 6+)
# ------------------------------------------------------------------------------

variable "ec2_instance_type" {
  type        = string
  description = "ARM Graviton instance for Docker / Spring Boot."
  default     = "t4g.micro"
}

variable "ec2_key_name" {
  type        = string
  description = "Optional EC2 key pair for SSH (SSM preferred)."
  default     = null
}

# ------------------------------------------------------------------------------
# CI/CD (optional — IAM only, no extra AWS service cost)
# ------------------------------------------------------------------------------

variable "github_repository" {
  type        = string
  description = "GitHub repo (org/repo) for frontend deploy OIDC role. Leave empty to skip."
  default     = ""
}

variable "create_github_oidc_provider" {
  type        = bool
  description = "Create GitHub OIDC provider (false if already exists in account)."
  default     = true
}
