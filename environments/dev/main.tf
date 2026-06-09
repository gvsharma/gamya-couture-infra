# ------------------------------------------------------------------------------
# Dev environment — minimal API stack for Vercel frontend (ap-south-1)
# VPC + public subnet + private RDS subnets + EC2 (Amazon Linux 2023, t3.micro)
# + cheapest PostgreSQL RDS (private, EC2 SG → RDS SG only)
# ------------------------------------------------------------------------------

module "vpc" {
  source = "../../modules/vpc-minimal"

  name_prefix = local.name_prefix
  vpc_cidr    = var.vpc_cidr
}

module "security_groups" {
  source = "../../modules/security-groups-api"

  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id
  admin_cidr  = var.admin_cidr
  enable_ssh  = var.enable_ssh
}

module "rds" {
  source = "../../modules/rds"

  name_prefix            = local.name_prefix
  private_subnet_ids     = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.security_groups.rds_security_group_id]
  db_name                = var.db_name
  db_username            = var.db_username
  parameter_store_prefix = local.db_parameter_store_prefix
}

module "backend_deploy_artifacts" {
  count  = var.enable_backend_ssm_deploy ? 1 : 0
  source = "../../modules/backend-deploy-s3"

  name_prefix = local.name_prefix
}

module "ec2" {
  source = "../../modules/ec2-api"

  name_prefix        = local.name_prefix
  subnet_id          = module.vpc.public_subnet_id
  security_group_ids = [module.security_groups.security_group_id]
  instance_type      = var.ec2_instance_type
  key_name           = var.ec2_key_name
  api_port           = var.api_port
  ssh_authorized_keys = var.ssh_authorized_keys
  db_endpoint        = module.rds.db_endpoint
  db_name            = var.db_name
  db_username        = var.db_username

  # cloud-init runs at launch only — replace EC2 when bootstrap content changes.
  user_data_replace_on_change = length(var.ssh_authorized_keys) > 0 || var.enable_backend_ssm_deploy

  db_parameter_store_prefix = local.db_parameter_store_prefix
  additional_iam_policy_arns = var.enable_backend_ssm_deploy ? {
    backend_deploy_s3 = module.backend_deploy_artifacts[0].ec2_read_policy_arn
  } : {}
}

module "ci_backend_deploy" {
  count  = var.enable_backend_ssm_deploy ? 1 : 0
  source = "../../modules/ci-backend-deploy-iam"

  name_prefix       = local.name_prefix
  github_repository = var.github_backend_repository
  deploy_bucket_arn = module.backend_deploy_artifacts[0].bucket_arn
  ec2_instance_arn  = module.ec2.instance_arn
  create_oidc_provider = false

  allowed_ref_subjects = [
    "repo:${var.github_backend_repository}:ref:refs/heads/main",
  ]
}

module "scheduler" {
  count  = var.enable_cost_schedule ? 1 : 0
  source = "../../modules/scheduler"

  name_prefix            = local.name_prefix
  db_instance_identifier = local.rds_instance_identifier
  ec2_instance_id        = module.ec2.instance_id
  schedule_rds           = true
  schedule_ec2           = true

  timezone                  = var.schedule_timezone
  stop_schedule_expression  = var.schedule_stop_expression
  start_schedule_expression = var.schedule_start_expression
  enabled                   = true
}
