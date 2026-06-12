variable "aws_region" {
  type        = string
  description = "AWS region for IAM resources (IAM is global; provider region for API calls)."
  default     = "ap-south-1"
}

variable "aws_account_id" {
  type        = string
  description = "Expected AWS account ID."
  default     = "085863558134"
}

variable "github_repository" {
  type    = string
  default = "gvsharma/gamya-couture-infra"
}

variable "role_name" {
  type    = string
  default = "GitHubTerraformRole"
}

variable "create_oidc_provider" {
  type        = bool
  description = "Create OIDC provider (false if already exists)."
  default     = true
}

variable "attach_administrator_access" {
  type    = bool
  default = true
}
