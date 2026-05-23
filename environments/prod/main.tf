# ------------------------------------------------------------------------------
# Root composition
# ------------------------------------------------------------------------------

locals {
  name_prefix = "${var.project}-${var.environment}"
}

module "networking" {
  source = "../../modules/networking"

  name_prefix = local.name_prefix
  vpc_cidr    = var.vpc_cidr
}

# Phase 3: module "security_groups" { ... }
# Phase 4: module "rds" { ... }
# Phase 5: module "scheduler" { ... }
# Phase 6: module "ec2" { ... }
