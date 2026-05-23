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
  description = "SSH allowlist CIDR."
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
  description = "Dev can disable schedule or share smaller window."
  default     = false
}

variable "ec2_instance_type" {
  type    = string
  default = "t4g.micro"
}
