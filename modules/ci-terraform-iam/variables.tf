variable "name_prefix" {
  type        = string
  description = "Prefix for IAM role and policy names."
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in org/repo format (e.g. gvsharma/gamya-couture-infra)."
}

variable "state_bucket_arn" {
  type        = string
  description = "ARN of the Terraform remote state S3 bucket."
}

variable "lock_table_arn" {
  type        = string
  description = "ARN of the DynamoDB state lock table."
}

variable "create_oidc_provider" {
  type        = bool
  description = "Create the GitHub OIDC provider (false if it already exists in the account)."
  default     = true
}

variable "github_oidc_thumbprint" {
  type        = string
  description = "GitHub Actions OIDC thumbprint."
  default     = "6938fd4d98bab03fa91895be9a8269eb296c0d62"
}

variable "allowed_ref_subjects" {
  type        = list(string)
  description = "GitHub OIDC sub claim patterns allowed to assume this role."
  default     = []
}

variable "default_allowed_subjects" {
  type        = list(string)
  description = "Default OIDC subjects when allowed_ref_subjects is empty."
  default = [
    "pull_request",
    "ref:refs/heads/main",
    "workflow_dispatch",
  ]
}
