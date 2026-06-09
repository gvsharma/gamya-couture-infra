variable "name_prefix" {
  type        = string
  description = "Prefix for resource names (e.g. gamya-couture-api)."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR for the single public subnet."
  default     = ""
}

variable "availability_zone" {
  type        = string
  description = "AZ for the public subnet. Leave empty to use the first available AZ."
  default     = ""
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private RDS subnets (two AZs). Auto-derived from vpc_cidr when empty."
  default     = []
}
