variable "name_prefix" {
  type        = string
  description = "Prefix for security group names (e.g. gamya-couture-prod)."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where security groups are created."
}

variable "admin_cidr" {
  type        = string
  description = "CIDR allowed for SSH (port 22) to EC2 when enable_ssh is true. Use /32 for a single admin IP."
  default     = "127.0.0.1/32"

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0))
    error_message = "admin_cidr must be a valid IPv4 CIDR block (e.g. 203.0.113.10/32)."
  }

  validation {
    condition     = !var.enable_ssh || endswith(var.admin_cidr, "/32")
    error_message = "When enable_ssh is true, admin_cidr must be a /32 host route (e.g. 203.0.113.10/32)."
  }
}

variable "enable_ssh" {
  type        = bool
  description = "Allow SSH (port 22) from admin_cidr. Prefer false and use SSM Session Manager."
  default     = false
}

variable "restrict_web_ingress_to_cloudfront" {
  type        = bool
  description = "Allow HTTP/HTTPS only from the CloudFront origin-facing managed prefix list."
  default     = true
}

variable "web_ingress_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed for HTTP/HTTPS when restrict_web_ingress_to_cloudfront is false."
  default     = ["0.0.0.0/0"]
}

variable "allow_ec2_all_egress" {
  type        = bool
  description = "Allow all outbound traffic from EC2 (needed for Docker pulls, apt, external APIs). Set false only if you add custom egress rules."
  default     = true
}
