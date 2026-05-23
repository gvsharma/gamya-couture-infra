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
