variable "name_prefix" {
  type        = string
  description = "Prefix for CloudFront resources."
}

variable "frontend_bucket_id" {
  type        = string
  description = "Frontend S3 bucket name."
}

variable "frontend_bucket_arn" {
  type        = string
  description = "Frontend S3 bucket ARN."
}

variable "frontend_bucket_regional_domain_name" {
  type        = string
  description = "Frontend bucket regional domain name."
}

variable "images_bucket_id" {
  type        = string
  description = "Product images bucket name."
}

variable "images_bucket_arn" {
  type        = string
  description = "Product images bucket ARN."
}

variable "images_bucket_regional_domain_name" {
  type        = string
  description = "Images bucket regional domain name."
}

variable "videos_bucket_id" {
  type        = string
  description = "Product videos bucket name."
}

variable "videos_bucket_arn" {
  type        = string
  description = "Product videos bucket ARN."
}

variable "videos_bucket_regional_domain_name" {
  type        = string
  description = "Videos bucket regional domain name."
}

variable "aliases" {
  type        = list(string)
  description = "Alternate domain names (requires acm_certificate_arn)."
  default     = []
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN in us-east-1 for custom domains (optional)."
  default     = null
}

variable "default_root_object" {
  type        = string
  default     = "index.html"
}

variable "price_class" {
  type        = string
  description = "CloudFront price class (PriceClass_100 = lowest cost)."
  default     = "PriceClass_100"
}

variable "enable_spa_fallback" {
  type        = bool
  description = "Map 403/404 to index.html for client-side routing."
  default     = true
}

variable "enable_media_behaviors" {
  type        = bool
  description = "Add /images/* and /videos/* cache behaviors."
  default     = true
}

variable "enable_image_optimization_headers" {
  type        = bool
  description = "Forward Accept header on /images/* for future image optimization."
  default     = true
}

variable "comment" {
  type        = string
  default     = "Gamya Couture CDN"
}

variable "enable_api_distribution" {
  type        = bool
  description = "Create a second distribution for api/admin → EC2 origin (HTTPS at edge)."
  default     = false
}

variable "api_aliases" {
  type        = list(string)
  description = "Alternate domain names for the API CloudFront distribution."
  default     = []
}

variable "api_origin_hostname" {
  type        = string
  description = "FQDN of the EC2 origin (e.g. origin-api.gamyacouture.com)."
  default     = ""
}

variable "api_origin_http_port" {
  type        = number
  description = "HTTP port on EC2/nginx."
  default     = 80
}
