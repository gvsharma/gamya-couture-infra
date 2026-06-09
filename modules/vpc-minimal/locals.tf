data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az                 = var.availability_zone != "" ? var.availability_zone : data.aws_availability_zones.available.names[0]
  public_subnet_cidr = var.public_subnet_cidr != "" ? var.public_subnet_cidr : cidrsubnet(var.vpc_cidr, 8, 1)
}
