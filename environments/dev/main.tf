data "aws_caller_identity" "current" {}

locals {
  name_prefix               = "${var.project}-${var.environment}"
  db_parameter_store_prefix = "/${var.project}/${var.environment}/db"

  enable_custom_domain       = var.domain_name != ""
  restrict_ec2_to_cloudfront = var.restrict_web_ingress_to_cloudfront && local.enable_custom_domain
  www_fqdn                   = "${var.www_subdomain}.${var.domain_name}"
  api_fqdn             = "${var.api_subdomain}.${var.domain_name}"
  admin_fqdn           = "${var.admin_subdomain}.${var.domain_name}"
  origin_api_fqdn      = "origin-api-${var.environment}.${var.domain_name}"

  web_aliases = local.enable_custom_domain ? [local.www_fqdn] : []
  api_aliases = local.enable_custom_domain ? [local.api_fqdn, local.admin_fqdn] : []
}

module "networking" {
  source = "../../modules/networking"

  name_prefix = local.name_prefix
  vpc_cidr    = var.vpc_cidr
}

module "security_groups" {
  source = "../../modules/security-groups"

  name_prefix                        = local.name_prefix
  vpc_id                             = module.networking.vpc_id
  admin_cidr                         = var.admin_cidr
  enable_ssh                         = var.enable_ssh
  restrict_web_ingress_to_cloudfront = local.restrict_ec2_to_cloudfront
  web_ingress_cidr_blocks            = var.web_ingress_cidr_blocks
}

module "route53" {
  count  = local.enable_custom_domain ? 1 : 0
  source = "../../modules/route53"

  domain_name = var.domain_name
}

module "acm" {
  count  = local.enable_custom_domain ? 1 : 0
  source = "../../modules/acm"

  providers = {
    aws = aws.us_east_1
  }

  domain_name = var.domain_name
  subject_alternative_names = [
    local.www_fqdn,
    local.api_fqdn,
    local.admin_fqdn,
  ]
  route53_zone_id = module.route53[0].zone_id
}

module "s3" {
  source = "../../modules/s3"

  name_prefix           = local.name_prefix
  bucket_suffix         = data.aws_caller_identity.current.account_id
  force_destroy_buckets = true
}

module "rds" {
  source = "../../modules/rds"

  name_prefix            = local.name_prefix
  private_subnet_ids     = module.networking.private_subnet_ids
  vpc_security_group_ids = [module.security_groups.rds_security_group_id]
  db_name                = var.db_name
  db_username            = var.db_username
  parameter_store_prefix = local.db_parameter_store_prefix
}

module "ec2" {
  source = "../../modules/ec2"

  name_prefix        = local.name_prefix
  environment        = var.environment
  subnet_id          = module.networking.public_subnet_ids[0]
  security_group_ids = [module.security_groups.ec2_security_group_id]
  instance_type      = var.ec2_instance_type
  key_name           = var.ec2_key_name

  additional_iam_policy_arns = compact([
    module.rds.db_secrets_read_policy_arn,
    module.s3.ec2_media_upload_policy_arn,
  ])
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  name_prefix = local.name_prefix

  frontend_bucket_id                   = module.s3.frontend_bucket_id
  frontend_bucket_arn                  = module.s3.frontend_bucket_arn
  frontend_bucket_regional_domain_name = module.s3.frontend_bucket_regional_domain_name

  images_bucket_id                   = module.s3.images_bucket_id
  images_bucket_arn                  = module.s3.images_bucket_arn
  images_bucket_regional_domain_name = module.s3.images_bucket_regional_domain_name

  videos_bucket_id                   = module.s3.videos_bucket_id
  videos_bucket_arn                  = module.s3.videos_bucket_arn
  videos_bucket_regional_domain_name = module.s3.videos_bucket_regional_domain_name

  aliases             = local.web_aliases
  acm_certificate_arn = local.enable_custom_domain ? module.acm[0].certificate_arn_validated : null

  enable_api_distribution = local.enable_custom_domain
  api_aliases             = local.api_aliases
  api_origin_hostname     = local.origin_api_fqdn
}

module "route53_records" {
  count  = local.enable_custom_domain ? 1 : 0
  source = "../../modules/route53-records"

  zone_id = module.route53[0].zone_id

  domain_name = var.domain_name
  www_fqdn    = local.www_fqdn
  api_fqdn    = local.api_fqdn
  admin_fqdn  = local.admin_fqdn

  origin_api_fqdn = local.origin_api_fqdn
  ec2_public_ip   = module.ec2.public_ip

  web_cloudfront_domain_name = module.cloudfront.distribution_domain_name
  web_cloudfront_zone_id     = module.cloudfront.distribution_hosted_zone_id

  api_cloudfront_domain_name = module.cloudfront.api_distribution_domain_name
  api_cloudfront_zone_id     = module.cloudfront.api_distribution_hosted_zone_id
}

module "scheduler" {
  count  = var.enable_rds_schedule ? 1 : 0
  source = "../../modules/scheduler"

  name_prefix            = local.name_prefix
  db_instance_identifier = module.rds.db_instance_id
  db_instance_arn        = module.rds.db_instance_arn
  enabled                = true
}

module "ci_deploy" {
  count  = var.github_repository != "" ? 1 : 0
  source = "../../modules/ci-deploy-iam"

  name_prefix                 = local.name_prefix
  github_repository           = var.github_repository
  frontend_bucket_arn         = module.s3.frontend_bucket_arn
  cloudfront_distribution_arn = module.cloudfront.distribution_arn
  create_oidc_provider        = var.create_github_oidc_provider
}
