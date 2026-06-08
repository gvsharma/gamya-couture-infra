locals {
  name_prefix               = "${var.project}-${var.environment}"
  db_parameter_store_prefix = "/${var.project}/${var.environment}/db"

  enable_custom_domain       = var.domain_name != ""
  restrict_ec2_to_cloudfront = var.restrict_web_ingress_to_cloudfront && local.enable_custom_domain

  www_fqdn        = local.enable_custom_domain ? "${var.www_subdomain}.${var.domain_name}" : ""
  api_fqdn        = local.enable_custom_domain ? "${var.api_subdomain}.${var.domain_name}" : ""
  admin_fqdn      = local.enable_custom_domain ? "${var.admin_subdomain}.${var.domain_name}" : ""
  origin_api_fqdn = local.enable_custom_domain ? "origin-api.${var.domain_name}" : ""

  web_aliases = local.enable_custom_domain ? [var.domain_name, local.www_fqdn] : []
  api_aliases = local.enable_custom_domain ? [local.api_fqdn, local.admin_fqdn] : []
}
