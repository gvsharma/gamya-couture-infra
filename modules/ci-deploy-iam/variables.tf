variable "name_prefix" {
  type        = string
  description = "Prefix for IAM role and policy names."
}

variable "github_repository" {
  type        = string
  description = "GitHub repository allowed to assume the role (org/repo format)."
}

variable "frontend_bucket_arn" {
  type        = string
  description = "S3 bucket ARN for Next.js static deploy (sync target)."
}

variable "cloudfront_distribution_arn" {
  type        = string
  description = "CloudFront distribution ARN for cache invalidation."
}

variable "create_oidc_provider" {
  type        = bool
  description = "Create the GitHub OIDC provider (set false if it already exists in the account)."
  default     = true
}

variable "github_oidc_thumbprint" {
  type        = string
  description = "GitHub Actions OIDC thumbprint (update if GitHub rotates certificates)."
  default     = "6938fd4d98bab03fa91895be9a8269eb296c0d62"
}

variable "allowed_ref_subjects" {
  type        = list(string)
  description = "Additional GitHub OIDC sub claim patterns (e.g. repo:org/repo:ref:refs/heads/main)."
  default     = []
}
