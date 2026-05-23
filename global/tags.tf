# Shared tagging — merged into provider default_tags in each environment.

variable "project" {
  type        = string
  description = "Project name for cost allocation."
  default     = "gamya-couture"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, prod)."
}

variable "owner" {
  type        = string
  description = "Team or individual responsible for the stack."
  default     = "platform"
}

variable "cost_center" {
  type        = string
  description = "Cost center or billing code."
  default     = "mvp"
}

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
  }
}

output "common_tags" {
  description = "Default tags applied to all resources via provider default_tags."
  value       = local.common_tags
}
