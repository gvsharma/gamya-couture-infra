output "environment" {
  description = "Active environment name."
  value       = var.environment
}

output "aws_region" {
  description = "Primary AWS region."
  value       = var.aws_region
}

# ------------------------------------------------------------------------------
# Networking
# ------------------------------------------------------------------------------

output "vpc_id" {
  description = "VPC ID."
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block."
  value       = module.networking.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs for EC2."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs for RDS."
  value       = module.networking.private_subnet_ids
}

output "availability_zones" {
  description = "AZs used by subnets."
  value       = module.networking.availability_zones
}
