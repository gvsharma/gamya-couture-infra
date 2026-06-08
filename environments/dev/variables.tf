variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project" {
  type    = string
  default = "gamya-couture"
}

variable "owner" {
  type    = string
  default = "platform"
}

variable "cost_center" {
  type    = string
  default = "mvp"
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "admin_cidr" {
  type        = string
  description = "SSH allowlist CIDR when enable_ssh is true (must be /32)."
  default     = "127.0.0.1/32"
}

variable "enable_ssh" {
  type        = bool
  description = "Allow SSH to EC2. Dev may enable for debugging; prefer SSM."
  default     = false
}

variable "restrict_web_ingress_to_cloudfront" {
  type        = bool
  description = "Restrict EC2 HTTP/HTTPS to CloudFront. Set false for direct API testing via EIP."
  default     = false
}

variable "web_ingress_cidr_blocks" {
  type        = list(string)
  description = "HTTP/HTTPS CIDR allowlist when CloudFront restriction is disabled."
  default     = ["0.0.0.0/0"]
}

variable "domain_name" {
  type    = string
  default = ""
}

variable "api_subdomain" {
  type    = string
  default = "api-dev"
}

variable "www_subdomain" {
  type    = string
  default = "dev"
}

variable "admin_subdomain" {
  type    = string
  default = "admin-dev"
}

variable "db_name" {
  type    = string
  default = "gamya_dev"
}

variable "db_username" {
  type    = string
  default = "gamya_admin"
}

variable "enable_rds_schedule" {
  type        = bool
  description = "Stop RDS overnight in dev."
  default     = false
}

variable "ec2_instance_type" {
  type    = string
  default = "t4g.micro"
}

variable "ec2_key_name" {
  type    = string
  default = null
}

variable "github_repository" {
  type        = string
  description = "GitHub repo for frontend deploy OIDC. Leave empty to skip."
  default     = ""
}

variable "create_github_oidc_provider" {
  type        = bool
  description = "Create GitHub OIDC provider (set false if prod already created it)."
  default     = false
}
