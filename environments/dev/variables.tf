variable "aws_region" {
  type        = string
  description = "AWS region."
  default     = "ap-south-1"
}

variable "project" {
  type        = string
  description = "Project slug for naming (prefix: gamya-couture-dev)."
  default     = "gamya-couture"
}

variable "environment" {
  type        = string
  description = "Environment name — must be dev for this stack."
  default     = "dev"
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

variable "vpc_cidr" {
  type        = string
  description = "Dev VPC CIDR (isolated from prod)."
  default     = "10.50.0.0/16"
}

variable "admin_cidr" {
  type        = string
  description = "Your public IP for SSH (/32)."
  default     = "127.0.0.1/32"
}

variable "enable_ssh" {
  type        = bool
  description = "Allow SSH from admin_cidr only."
  default     = true
}

variable "ec2_instance_type" {
  type        = string
  description = "Dev API instance type."
  default     = "t3.micro"
}

variable "ec2_key_name" {
  type        = string
  description = "Optional EC2 key pair for SSH."
  default     = null
}

variable "ssh_authorized_keys" {
  type        = list(string)
  description = "Public keys for ec2-user authorized_keys at launch (optional admin SSH)."
  default     = []
}

variable "github_backend_repository" {
  type        = string
  description = "GitHub repo for backend deploy OIDC (org/repo)."
  default     = "gvsharma/gamyaboutique"
}

variable "github_token" {
  type        = string
  description = "GitHub PAT with repo scope on github_backend_repository. When set, Terraform manages gamyaboutique Actions deploy variables/secrets after apply."
  sensitive   = true
  default     = null
}

variable "enable_backend_ssm_deploy" {
  type        = bool
  description = "Create S3 deploy bucket + GitHub OIDC role for SSM-based backend deploy."
  default     = true
}


variable "enable_product_media_cdn" {
  type        = bool
  description = "CloudFront CDN + IAM for private S3 product images (gamya-couture-dev-media)."
  default     = true
}

variable "product_media_bucket_name" {
  type        = string
  description = "Existing S3 bucket for product images (used when enable_product_media_cdn=true)."
  default     = "gamya-couture-dev-media"
}

variable "product_media_manage_bucket" {
  type        = bool
  description = "Create the media bucket via Terraform. Keep false when the bucket already exists."
  default     = false
}

variable "api_port" {
  type        = number
  description = "Backend app port behind nginx."
  default     = 8080
}

variable "db_name" {
  type        = string
  description = "Initial PostgreSQL database name."
  default     = "gamya"
}

variable "db_username" {
  type        = string
  description = "RDS master username (stored in SSM Parameter Store)."
  default     = "gamya_admin"
}

# ------------------------------------------------------------------------------
# Cost scheduler (EC2 + RDS daily stop/start, IST)
# ------------------------------------------------------------------------------

variable "enable_cost_schedule" {
  type        = bool
  description = "Enable daily EC2+RDS stop (00:00 IST) and start (09:00 IST)."
  default     = true
}

variable "schedule_timezone" {
  type        = string
  description = "IANA timezone for cost scheduler."
  default     = "Asia/Kolkata"
}

variable "schedule_stop_expression" {
  type        = string
  description = "EventBridge cron for nightly stop (default 12:00 AM in schedule_timezone)."
  default     = "cron(0 0 * * ? *)"
}

variable "schedule_start_expression" {
  type        = string
  description = "EventBridge cron for morning start (default 9:00 AM in schedule_timezone)."
  default     = "cron(0 9 * * ? *)"
}
