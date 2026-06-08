variable "aws_region" {
  type        = string
  description = "AWS region."
  default     = "ap-south-1"
}

variable "project" {
  type        = string
  description = "Project slug for naming."
  default     = "gamya-couture"
}

variable "environment" {
  type        = string
  description = "Environment name."
  default     = "api"
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
  description = "VPC CIDR block."
  default     = "10.50.0.0/16"
}

variable "admin_cidr" {
  type        = string
  description = "Your public IP for SSH (/32)."
}

variable "enable_ssh" {
  type        = bool
  description = "Allow SSH from admin_cidr."
  default     = true
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro"
}

variable "ec2_key_name" {
  type        = string
  description = "EC2 key pair for SSH (optional if using SSM)."
  default     = null
}

variable "api_port" {
  type        = number
  description = "Backend application port (Vercel calls nginx on 80)."
  default     = 8080
}
