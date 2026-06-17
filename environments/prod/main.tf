# ------------------------------------------------------------------------------
# Gamya Couture — production root module (ap-south-1)
# Naming prefix: gamya-couture-prod (var.project + var.environment)
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# Core network & compute (required)
# ------------------------------------------------------------------------------

module "vpc" {
  source = "../../modules/vpc"

  name_prefix = local.name_prefix
  vpc_cidr    = var.vpc_cidr
}

module "security_groups" {
  source = "../../modules/security-groups"

  name_prefix                        = local.name_prefix
  vpc_id                             = module.vpc.vpc_id
  admin_cidr                         = var.admin_cidr
  enable_ssh                         = var.enable_ssh
  restrict_web_ingress_to_cloudfront = local.restrict_ec2_to_cloudfront
  web_ingress_cidr_blocks            = var.web_ingress_cidr_blocks
}

# ------------------------------------------------------------------------------
# DNS & TLS (optional — set domain_name in tfvars)
# ------------------------------------------------------------------------------

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

# ------------------------------------------------------------------------------
# Storage & CDN
# ------------------------------------------------------------------------------

module "s3" {
  source = "../../modules/s3"

  name_prefix   = local.name_prefix
  bucket_suffix = data.aws_caller_identity.current.account_id
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

# ------------------------------------------------------------------------------
# Database & cost scheduler
# ------------------------------------------------------------------------------

module "rds" {
  source = "../../modules/rds"

  name_prefix            = local.name_prefix
  private_subnet_ids     = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.security_groups.rds_security_group_id]
  db_name                = var.db_name
  db_username            = var.db_username
  parameter_store_prefix = local.db_parameter_store_prefix
}

module "ec2" {
  source = "../../modules/ec2"

  name_prefix        = local.name_prefix
  environment        = var.environment
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.security_groups.ec2_security_group_id]
  instance_type      = var.ec2_instance_type
  key_name           = var.ec2_key_name

  additional_iam_policy_arns = compact([
    module.rds.db_secrets_read_policy_arn,
    module.s3.ec2_media_upload_policy_arn,
  ])
}

module "scheduler" {
  count  = var.enable_cost_schedule ? 1 : 0
  source = "../../modules/scheduler"

  name_prefix            = local.name_prefix
  db_instance_identifier = substr(replace("${local.name_prefix}-pg", "_", "-"), 0, 63)
  ec2_instance_id        = module.ec2.instance_id
  schedule_rds           = true
  schedule_ec2           = true

  timezone        = var.schedule_timezone
  start_schedules = var.schedule_start_overrides
  stop_schedules  = var.schedule_stop_overrides
  enabled         = true
}

# ------------------------------------------------------------------------------
# CI/CD (optional)
# ------------------------------------------------------------------------------

module "ci_deploy" {
  count  = var.github_repository != "" ? 1 : 0
  source = "../../modules/ci-deploy-iam"

  name_prefix                 = local.name_prefix
  github_repository           = var.github_repository
  frontend_bucket_arn         = module.s3.frontend_bucket_arn
  cloudfront_distribution_arn = module.cloudfront.distribution_arn
  create_oidc_provider        = var.create_github_oidc_provider
}

# ------------------------------------------------------------------------------
# Future: ALB (modules/alb) — wire when migrating API behind a load balancer
# ------------------------------------------------------------------------------
