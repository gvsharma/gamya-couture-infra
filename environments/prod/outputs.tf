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
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block."
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs for EC2."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs for RDS."
  value       = module.vpc.private_subnet_ids
}

output "availability_zones" {
  description = "AZs used by subnets."
  value       = module.vpc.availability_zones
}

# ------------------------------------------------------------------------------
# Security groups
# ------------------------------------------------------------------------------

output "ec2_security_group_id" {
  description = "EC2 application security group ID."
  value       = module.security_groups.ec2_security_group_id
}

output "rds_security_group_id" {
  description = "RDS PostgreSQL security group ID."
  value       = module.security_groups.rds_security_group_id
}

# ------------------------------------------------------------------------------
# EC2
# ------------------------------------------------------------------------------

output "ec2_instance_id" {
  description = "Application EC2 instance ID (SSM target)."
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Elastic IP for API DNS (Route53 A record)."
  value       = module.ec2.public_ip
}

output "ec2_private_ip" {
  description = "EC2 private IP."
  value       = module.ec2.private_ip
}

# ------------------------------------------------------------------------------
# RDS
# ------------------------------------------------------------------------------

output "db_endpoint" {
  description = "RDS hostname."
  value       = module.rds.db_endpoint
}

output "db_port" {
  description = "RDS port."
  value       = module.rds.db_port
}

output "db_name" {
  description = "PostgreSQL database name."
  value       = module.rds.db_name
}

output "jdbc_url" {
  description = "JDBC URL (credentials from SSM)."
  value       = module.rds.jdbc_url
}

output "ssm_db_username_parameter" {
  description = "SSM parameter name for DB username."
  value       = module.rds.ssm_parameter_username_name
}

output "ssm_db_password_parameter" {
  description = "SSM parameter name for DB password."
  value       = module.rds.ssm_parameter_password_name
}

# ------------------------------------------------------------------------------
# RDS scheduler
# ------------------------------------------------------------------------------

output "rds_schedule_enabled" {
  description = "Whether daily RDS stop/start schedules are active."
  value       = var.enable_rds_schedule
}

output "rds_stop_schedule_local" {
  description = "RDS stop time in IST."
  value       = try(module.scheduler[0].stop_schedule_local_time, null)
}

output "rds_start_schedule_local" {
  description = "RDS start time in IST."
  value       = try(module.scheduler[0].start_schedule_local_time, null)
}

# ------------------------------------------------------------------------------
# S3 & CloudFront
# ------------------------------------------------------------------------------

output "frontend_bucket_id" {
  description = "S3 bucket for Next.js static export."
  value       = module.s3.frontend_bucket_id
}

output "images_bucket_id" {
  description = "S3 bucket for product images."
  value       = module.s3.images_bucket_id
}

output "videos_bucket_id" {
  description = "S3 bucket for product videos."
  value       = module.s3.videos_bucket_id
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID."
  value       = module.cloudfront.distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain for the website."
  value       = module.cloudfront.distribution_domain_name
}

output "cloudfront_url" {
  description = "HTTPS URL for the static frontend."
  value       = module.cloudfront.frontend_url
}

output "cdn_images_base_url" {
  description = "CDN base URL for images (/images/*)."
  value       = module.cloudfront.images_cdn_path
}

output "cdn_videos_base_url" {
  description = "CDN base URL for videos (/videos/*)."
  value       = module.cloudfront.videos_cdn_path
}

# ------------------------------------------------------------------------------
# DNS & TLS
# ------------------------------------------------------------------------------

output "route53_name_servers" {
  description = "Delegate at registrar for gamyacouture.com."
  value       = try(module.route53[0].name_servers, null)
}

output "acm_certificate_arn" {
  description = "Validated ACM certificate ARN (us-east-1)."
  value       = try(module.acm[0].certificate_arn_validated, null)
}

output "website_url" {
  description = "Production storefront URL."
  value       = try(module.route53_records[0].website_urls.www, module.cloudfront.frontend_url)
}

output "api_url" {
  description = "Production API URL."
  value       = try(module.route53_records[0].api_url, null)
}

output "admin_url" {
  description = "Production admin URL."
  value       = try(module.route53_records[0].admin_url, null)
}

output "github_deploy_role_arn" {
  description = "IAM role ARN for GitHub Actions frontend deploy."
  value       = try(module.ci_deploy[0].deploy_role_arn, null)
}
