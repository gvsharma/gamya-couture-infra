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
  description = "CIDR allowed for SSH (port 22) to EC2. Use /32 for a single admin IP."

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0))
    error_message = "admin_cidr must be a valid IPv4 CIDR block (e.g. 203.0.113.10/32)."
  }
}

variable "web_ingress_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed for HTTP/HTTPS to the EC2 app tier."
  default     = ["0.0.0.0/0"]
}

variable "allow_ec2_all_egress" {
  type        = bool
  description = "Allow all outbound traffic from EC2 (needed for Docker pulls, apt, external APIs). Set false only if you add custom egress rules."
  default     = true
}
