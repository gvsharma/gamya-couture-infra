data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
  az  = var.availability_zone != "" ? var.availability_zone : local.azs[0]

  public_subnet_cidr = var.public_subnet_cidr != "" ? var.public_subnet_cidr : cidrsubnet(var.vpc_cidr, 8, 1)

  private_subnet_cidrs = length(var.private_subnet_cidrs) > 0 ? var.private_subnet_cidrs : [
    cidrsubnet(var.vpc_cidr, 8, 11),
    cidrsubnet(var.vpc_cidr, 8, 12),
  ]
}
