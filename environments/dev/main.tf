locals {
  name_prefix = "${var.project}-${var.environment}"
}

module "networking" {
  source = "../../modules/networking"

  name_prefix = local.name_prefix
  vpc_cidr    = var.vpc_cidr
}
