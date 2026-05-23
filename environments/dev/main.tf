data "aws_caller_identity" "current" {}

locals {
  name_prefix               = "${var.project}-${var.environment}"
  db_parameter_store_prefix = "/${var.project}/${var.environment}/db"
}

module "networking" {
  source = "../../modules/networking"

  name_prefix = local.name_prefix
  vpc_cidr    = var.vpc_cidr
}

module "security_groups" {
  source = "../../modules/security-groups"

  name_prefix = local.name_prefix
  vpc_id      = module.networking.vpc_id
  admin_cidr  = var.admin_cidr
}

module "s3" {
  source = "../../modules/s3"

  name_prefix          = local.name_prefix
  bucket_suffix        = data.aws_caller_identity.current.account_id
  force_destroy_buckets = true
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

module "scheduler" {
  count  = var.enable_rds_schedule ? 1 : 0
  source = "../../modules/scheduler"

  name_prefix            = local.name_prefix
  db_instance_identifier = module.rds.db_instance_id
  db_instance_arn        = module.rds.db_instance_arn
  enabled                = true
}
