output "website_urls" {
  description = "Public HTTPS URLs for the storefront."
  value = {
    apex = "https://${var.domain_name}"
    www  = "https://${var.www_fqdn}"
  }
}

output "api_url" {
  description = "Public HTTPS API URL."
  value       = "https://${var.api_fqdn}"
}

output "admin_url" {
  description = "Public HTTPS admin URL."
  value       = "https://${var.admin_fqdn}"
}

output "origin_api_fqdn" {
  description = "Direct origin hostname (not for public clients)."
  value       = var.origin_api_fqdn
}
