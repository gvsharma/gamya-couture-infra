variable "name_prefix" {
  type        = string
  description = "Prefix for security group names."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "admin_cidr" {
  type        = string
  description = "CIDR allowed for SSH (use /32 for your public IP)."
  default     = "127.0.0.1/32"

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0))
    error_message = "admin_cidr must be a valid IPv4 CIDR."
  }

  validation {
    condition     = !var.enable_ssh || endswith(var.admin_cidr, "/32")
    error_message = "When enable_ssh is true, admin_cidr must be a /32 host route."
  }
}

variable "enable_ssh" {
  type        = bool
  description = "Allow SSH from admin_cidr only."
  default     = true
}

variable "http_https_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed for HTTP/HTTPS (Vercel + public API clients)."
  default     = ["0.0.0.0/0"]
}
