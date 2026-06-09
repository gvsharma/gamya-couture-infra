variable "name_prefix" {
  type        = string
  description = "Prefix for resource names (e.g. gamya-couture-prod)."
}

variable "bucket_suffix" {
  type        = string
  description = "Globally unique suffix (typically AWS account ID)."
}

variable "force_destroy_buckets" {
  type        = bool
  description = "Allow Terraform to empty and delete buckets (non-prod only)."
  default     = false
}

variable "enable_versioning" {
  type        = bool
  description = "Enable versioning on all buckets (rollback for static site deploys)."
  default     = true
}

variable "images_transition_to_ia_days" {
  type        = number
  description = "Days before product images transition to STANDARD_IA (0 = disabled)."
  default     = 0
}

variable "videos_transition_to_ia_days" {
  type        = number
  description = "Days before product videos transition to STANDARD_IA."
  default     = 90
}

variable "abort_multipart_upload_days" {
  type        = number
  description = "Abort incomplete multipart uploads after N days."
  default     = 7
}

variable "create_ec2_media_upload_policy" {
  type        = bool
  description = "Create IAM policy for EC2 to upload product images/videos."
  default     = true
}
