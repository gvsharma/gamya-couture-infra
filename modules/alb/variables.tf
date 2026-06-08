variable "name_prefix" {
  type        = string
  description = "Prefix for ALB resource names (e.g. gamya-couture-prod)."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the load balancer."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for the ALB."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups attached to the ALB."
}
