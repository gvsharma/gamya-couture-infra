output "environment" {
  value = var.environment
}

output "aws_region" {
  value = var.aws_region
}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "vpc_cidr_block" {
  value = module.networking.vpc_cidr_block
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "availability_zones" {
  value = module.networking.availability_zones
}
