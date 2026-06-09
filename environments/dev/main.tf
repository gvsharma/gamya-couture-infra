# ------------------------------------------------------------------------------
# Dev environment — minimal API stack for Vercel frontend (ap-south-1)
# VPC + public subnet + IGW + EC2 (Amazon Linux 2023, t3.micro)
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

module "ec2" {
  source = "../../modules/ec2-api"

  name_prefix        = local.name_prefix
  subnet_id          = module.vpc.public_subnet_id
  security_group_ids = [module.security_groups.security_group_id]
  instance_type      = var.ec2_instance_type
  key_name           = var.ec2_key_name
  api_port           = var.api_port
}
