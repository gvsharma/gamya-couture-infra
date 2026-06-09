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

module "ec2" {
  source = "../../modules/ec2-api"

  name_prefix        = local.name_prefix
  subnet_id          = module.vpc.public_subnet_id
  security_group_ids = [module.security_groups.security_group_id]
  instance_type      = var.ec2_instance_type
  key_name           = var.ec2_key_name
  api_port           = var.api_port

  db_parameter_store_prefix = local.db_parameter_store_prefix
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
