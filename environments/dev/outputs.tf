output "environment" {
  description = "Deployment environment."
  value       = var.environment
}

output "aws_region" {
  description = "AWS region."
  value       = var.aws_region
}

output "name_prefix" {
  description = "Resource naming prefix."
  value       = local.name_prefix
}

output "vpc_id" {
  description = "Dev VPC ID."
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "Dev public subnet ID."
  value       = module.vpc.public_subnet_id
}

output "security_group_id" {
  description = "Dev API security group ID."
  value       = module.security_groups.security_group_id
}

output "rds_security_group_id" {
  description = "RDS PostgreSQL security group ID."
  value       = module.security_groups.rds_security_group_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for RDS."
  value       = module.vpc.private_subnet_ids
}

output "ec2_instance_id" {
  description = "Dev API EC2 instance ID."
  value       = module.ec2.instance_id
}

output "api_public_ip" {
  description = "Dev API Elastic IP — use in Vercel env vars."
  value       = module.ec2.public_ip
}

output "api_url" {
  description = "Dev API base URL (HTTP)."
  value       = module.ec2.api_url
}

output "health_url" {
  description = "Dev health check URL."
  value       = module.ec2.health_url
}

output "vercel_env_hint" {
  description = "Set in Vercel project (dev/preview)."
  value       = "NEXT_PUBLIC_API_URL=${module.ec2.api_url}"
}

# ------------------------------------------------------------------------------
# RDS
# ------------------------------------------------------------------------------

output "db_endpoint" {
  description = "RDS hostname (private; reachable from API EC2 only)."
  value       = module.rds.db_endpoint
}

output "db_port" {
  description = "PostgreSQL port."
  value       = module.rds.db_port
}

output "db_name" {
  description = "PostgreSQL database name."
  value       = module.rds.db_name
}

output "jdbc_url" {
  description = "JDBC URL (password from SSM Parameter Store)."
  value       = module.rds.jdbc_url
}

output "ssm_db_username_parameter" {
  description = "SSM Parameter Store path for DB username."
  value       = module.rds.ssm_parameter_username_name
}

output "ssm_db_password_parameter" {
  description = "SSM Parameter Store path for DB password."
  value       = module.rds.ssm_parameter_password_name
}

output "ssm_db_username_parameter_arn" {
  description = "SSM parameter ARN for DB username."
  value       = module.rds.ssm_parameter_username_arn
}

output "ssm_db_password_parameter_arn" {
  description = "SSM parameter ARN for DB password."
  value       = module.rds.ssm_parameter_password_arn
}

# ------------------------------------------------------------------------------
# Cost scheduler
# ------------------------------------------------------------------------------

output "cost_schedule_enabled" {
  description = "Whether daily EC2+RDS stop/start is active."
  value       = var.enable_cost_schedule
}

output "cost_schedule_timezone" {
  description = "Scheduler timezone."
  value       = try(module.scheduler[0].timezone, var.schedule_timezone)
}

output "cost_schedule_stop_local" {
  description = "Nightly stop time (IST by default)."
  value       = try(module.scheduler[0].stop_schedule_local_time, null)
}

output "cost_schedule_start_local" {
  description = "Morning start time (IST by default)."
  value       = try(module.scheduler[0].start_schedule_local_time, null)
}

output "cost_scheduler_lambda_name" {
  description = "Cost scheduler Lambda function name."
  value       = try(module.scheduler[0].lambda_function_name, null)
}
