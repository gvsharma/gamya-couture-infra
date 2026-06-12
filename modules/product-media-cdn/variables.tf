variable "name_prefix" {
  type        = string
  description = "Resource naming prefix (e.g. gamya-couture-dev)."
}

variable "bucket_name" {
  type        = string
  description = "Existing or new S3 bucket for product images."
}

variable "manage_bucket" {
  type        = bool
  description = "Create and manage the S3 bucket. When false, bucket_name must already exist."
  default     = false
}

variable "object_key_prefix" {
  type        = string
  description = "S3 key prefix for EC2 upload IAM (e.g. products/)."
  default     = "products/"
}

variable "force_destroy_bucket" {
  type        = bool
  description = "Allow Terraform to delete bucket with objects (only when manage_bucket=true)."
  default     = false
}

variable "price_class" {
  type        = string
  description = "CloudFront price class."
  default     = "PriceClass_200"
}

variable "comment" {
  type        = string
  description = "CloudFront distribution comment."
  default     = "Product images CDN"
}
