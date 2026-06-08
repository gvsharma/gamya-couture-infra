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
  type    = string
  default = "platform"
}

variable "cost_center" {
  type    = string
  default = "mvp"
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

variable "api_port" {
  type        = number
  description = "Backend app port behind nginx."
  default     = 8080
}
