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
  default     = "gamya-couture-terraform-state"
}

variable "lock_table_name" {
  type        = string
  description = "DynamoDB table name for Terraform state locking."
  default     = "terraform-locks"
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

variable "aws_account_id" {
  type        = string
  description = "Expected AWS account ID (validated when GitHub Actions IAM is enabled)."
  default     = "085863558134"
}

variable "enable_github_actions" {
  type        = bool
  description = "Create IAM role for GitHub Actions Terraform plan/apply via OIDC."
  default     = false
}

variable "github_repository" {
  type        = string
  description = "GitHub repo for infra workflows (org/repo). Required when enable_github_actions is true."
  default     = "gvsharma/gamya-couture-infra"

  validation {
    condition     = !var.enable_github_actions || can(regex("^[^/]+/[^/]+$", var.github_repository))
    error_message = "github_repository must be org/repo format (e.g. gvsharma/gamya-couture-infra)."
  }
}

variable "github_terraform_role_name" {
  type        = string
  description = "IAM role name for GitHub Actions Terraform."
  default     = "GitHubTerraformRole"
}

variable "create_github_oidc_provider" {
  type        = bool
  description = "Create GitHub OIDC provider in this account (false if already exists)."
  default     = true
}

variable "github_attach_administrator_access" {
  type        = bool
  description = "Attach AdministratorAccess to GitHub Terraform role (scope down later)."
  default     = true
}
