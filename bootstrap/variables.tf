variable "aws_region" {
  type        = string
  description = "AWS region for the state bucket and lock table."
  default     = "ap-south-1"
}

variable "project" {
  type        = string
  description = "Project slug used in resource names and tags."
  default     = "gamya-couture"
}

variable "state_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terraform state."
  default     = "gamya-couture-tf-state"
}

variable "lock_table_name" {
  type        = string
  description = "DynamoDB table name for Terraform state locking."
  default     = "gamya-couture-tf-locks"
}

variable "terraform_state_iam_policy_name" {
  type        = string
  description = "Name of the IAM policy granting least-privilege state access."
  default     = "gamya-couture-terraform-state-access"
}

variable "enable_iam_policy" {
  type        = bool
  description = "Create a reusable IAM policy for Terraform operators (attach to user/role manually)."
  default     = true
}

variable "enable_github_actions" {
  type        = bool
  description = "Create IAM role for GitHub Actions Terraform plan/apply via OIDC."
  default     = false
}

variable "github_repository" {
  type        = string
  description = "GitHub repo for infra workflows (org/repo). Required when enable_github_actions is true."
  default     = ""

  validation {
    condition     = !var.enable_github_actions || (var.github_repository != "" && can(regex("^[^/]+/[^/]+$", var.github_repository)))
    error_message = "When enable_github_actions is true, github_repository must be set (e.g. gvsharma/gamya-couture-infra)."
  }
}

variable "create_github_oidc_provider" {
  type        = bool
  description = "Create GitHub OIDC provider in this account (false if already exists)."
  default     = true
}
