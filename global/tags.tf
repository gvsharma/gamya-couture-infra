# Centralized tagging — merged into provider default_tags in each environment.
# Resource-specific tags (Name, ResourcePurpose, Tier) are set per resource in modules.

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
  description = "Individual or team responsible for the stack."
  default     = "Venkat"
}

variable "cost_optimization" {
  type        = string
  description = "Whether cost controls (scheduling, minimal SKUs) are active."
  default     = "enabled"
}

variable "auto_shutdown" {
  type        = string
  description = "Whether daily auto stop/start scheduling is enabled for this environment."
  default     = "true"
}

locals {
  common_tags = {
    Project          = var.project
    Environment      = var.environment
    ManagedBy        = "terraform"
    Owner            = var.owner
    CostOptimization = var.cost_optimization
    AutoShutdown     = var.auto_shutdown
  }
}

output "common_tags" {
  description = "Default tags applied to all resources via provider default_tags."
  value       = local.common_tags
}
