variable "name_prefix" {
  type        = string
  description = "Prefix for resource names (e.g. gamya-couture-prod)."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "availability_zones" {
  type        = list(string)
  description = "Two AZ names for subnet placement. Leave empty to use the first two available AZs in the region."
  default     = []

  validation {
    condition     = length(var.availability_zones) == 0 || length(var.availability_zones) == 2
    error_message = "availability_zones must be empty (auto) or contain exactly two AZ names."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets (EC2). Must be two /24 (or smaller) non-overlapping blocks inside vpc_cidr."
  default     = []
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets (RDS). Must be two /24 (or smaller) non-overlapping blocks inside vpc_cidr."
  default     = []
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "Assign a public IPv4 address to instances launched in public subnets."
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in the VPC (recommended for RDS endpoints)."
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS resolution in the VPC."
  default     = true
}
