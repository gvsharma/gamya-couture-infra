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
