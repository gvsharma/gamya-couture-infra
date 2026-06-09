variable "zone_id" {
  type        = string
  description = "Route53 hosted zone ID."
}

variable "domain_name" {
  type        = string
  description = "Root domain (gamyacouture.com)."
}

variable "www_fqdn" {
  type        = string
  description = "WWW hostname (www.gamyacouture.com)."
}

variable "api_fqdn" {
  type        = string
  description = "API hostname (api.gamyacouture.com)."
}

variable "admin_fqdn" {
  type        = string
  description = "Admin hostname (admin.gamyacouture.com)."
}

variable "origin_api_fqdn" {
  type        = string
  description = "Direct origin hostname for CloudFront → EC2 (origin-api.gamyacouture.com)."
}

variable "ec2_public_ip" {
  type        = string
  description = "EC2 Elastic IP for origin-api A record."
}

variable "web_cloudfront_domain_name" {
  type        = string
  description = "CloudFront domain for static site distribution."
}

variable "web_cloudfront_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for web CloudFront alias."
}

variable "api_cloudfront_domain_name" {
  type        = string
  description = "CloudFront domain for API/admin distribution."
}

variable "api_cloudfront_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for API CloudFront alias."
}
