variable "domain_name" {
  type        = string
  description = "Primary domain on the certificate (apex)."
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "Additional FQDNs (www, api, admin)."
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for DNS validation records."
}

variable "wait_for_validation" {
  type        = bool
  description = "Wait until ACM marks the certificate as issued."
  default     = true
}
