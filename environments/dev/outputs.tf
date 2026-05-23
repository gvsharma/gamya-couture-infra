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

output "ec2_security_group_id" {
  value = module.security_groups.ec2_security_group_id
}

output "rds_security_group_id" {
  value = module.security_groups.rds_security_group_id
}

output "ec2_instance_id" {
  value = module.ec2.instance_id
}

output "ec2_public_ip" {
  value = module.ec2.public_ip
}

output "ec2_private_ip" {
  value = module.ec2.private_ip
}

output "db_endpoint" {
  value = module.rds.db_endpoint
}

output "db_port" {
  value = module.rds.db_port
}

output "db_name" {
  value = module.rds.db_name
}

output "jdbc_url" {
  value = module.rds.jdbc_url
}

output "ssm_db_username_parameter" {
  value = module.rds.ssm_parameter_username_name
}

output "ssm_db_password_parameter" {
  value = module.rds.ssm_parameter_password_name
}

output "rds_schedule_enabled" {
  value = var.enable_rds_schedule
}

output "frontend_bucket_id" {
  value = module.s3.frontend_bucket_id
}

output "cloudfront_url" {
  value = module.cloudfront.frontend_url
}

output "cloudfront_distribution_id" {
  value = module.cloudfront.distribution_id
}
