# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------

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

# ------------------------------------------------------------------------------
# Networking (module.vpc)
# ------------------------------------------------------------------------------

output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block."
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_id" {
  description = "Public subnet ID for EC2."
  value       = module.vpc.public_subnet_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for RDS."
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "Internet Gateway ID."
  value       = module.vpc.internet_gateway_id
}

output "availability_zones" {
  description = "AZs used by private RDS subnets."
  value       = module.vpc.availability_zones
}

# ------------------------------------------------------------------------------
# Security groups (module.security_groups)
# ------------------------------------------------------------------------------

output "ec2_security_group_id" {
  description = "API EC2 security group ID."
  value       = module.security_groups.security_group_id
}

output "ec2_security_group_arn" {
  description = "API EC2 security group ARN."
  value       = module.security_groups.security_group_arn
}

output "rds_security_group_id" {
  description = "RDS PostgreSQL security group ID."
  value       = module.security_groups.rds_security_group_id
}

output "rds_security_group_arn" {
  description = "RDS PostgreSQL security group ARN."
  value       = module.security_groups.rds_security_group_arn
}

# ------------------------------------------------------------------------------
# EC2 API backend (module.ec2)
# ------------------------------------------------------------------------------

output "ec2_instance_id" {
  description = "API EC2 instance ID (SSM target)."
  value       = module.ec2.instance_id
}

output "ec2_instance_arn" {
  description = "API EC2 instance ARN."
  value       = module.ec2.instance_arn
}

output "ec2_instance_type" {
  description = "Provisioned EC2 instance type."
  value       = var.ec2_instance_type
}

output "ec2_private_ip" {
  description = "EC2 private IP."
  value       = module.ec2.private_ip
}

output "api_public_ip" {
  description = "Elastic IP for Vercel / DNS A record."
  value       = module.ec2.public_ip
}

output "api_url" {
  description = "API base URL (HTTP)."
  value       = module.ec2.api_url
}

output "health_url" {
  description = "Health check URL."
  value       = module.ec2.health_url
}

output "vercel_env_hint" {
  description = "Set in Vercel project (dev/preview)."
  value       = "NEXT_PUBLIC_API_URL=${module.ec2.api_url}"
}

# ------------------------------------------------------------------------------
# RDS PostgreSQL (module.rds)
# ------------------------------------------------------------------------------

output "db_instance_id" {
  description = "RDS instance identifier."
  value       = module.rds.db_instance_id
}

output "db_instance_arn" {
  description = "RDS instance ARN."
  value       = module.rds.db_instance_arn
}

output "db_subnet_group_name" {
  description = "RDS DB subnet group name."
  value       = module.rds.db_subnet_group_name
}

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

output "db_username" {
  description = "RDS master username (also in SSM)."
  value       = module.rds.db_username
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

output "db_secrets_read_policy_arn" {
  description = "IAM policy ARN attached to EC2 for reading DB credentials."
  value       = module.rds.db_secrets_read_policy_arn
}

# ------------------------------------------------------------------------------
# Cost scheduler (module.scheduler)
# ------------------------------------------------------------------------------

output "cost_schedule_enabled" {
  description = "Whether daily EC2+RDS stop/start is active."
  value       = var.enable_cost_schedule
}

output "cost_schedule_timezone" {
  description = "Scheduler timezone."
  value       = try(module.scheduler[0].timezone, var.schedule_timezone)
}

output "cost_schedule_summary" {
  description = "Human-readable weekly availability windows (IST by default)."
  value       = try(module.scheduler[0].schedule_summary, null)
}

output "cost_schedule_stop_rules" {
  description = "Stop schedule rules (cron expression + local time)."
  value       = try(module.scheduler[0].stop_schedules, null)
}

output "cost_schedule_start_rules" {
  description = "Start schedule rules (cron expression + local time)."
  value       = try(module.scheduler[0].start_schedules, null)
}

output "cost_scheduler_lambda_name" {
  description = "Cost scheduler Lambda function name."
  value       = try(module.scheduler[0].lambda_function_name, null)
}

output "cost_scheduler_lambda_arn" {
  description = "Cost scheduler Lambda ARN."
  value       = try(module.scheduler[0].lambda_function_arn, null)
}

output "cost_schedule_stop_arns" {
  description = "EventBridge stop schedule ARNs (one per rule)."
  value       = try(module.scheduler[0].stop_schedule_arns, null)
}

output "cost_schedule_start_arns" {
  description = "EventBridge start schedule ARNs (one per rule)."
  value       = try(module.scheduler[0].start_schedule_arns, null)
}

# ------------------------------------------------------------------------------
# Backend SSM deploy (GitHub Actions → S3 → SSM → EC2)
# ------------------------------------------------------------------------------

output "backend_deploy_enabled" {
  description = "Whether SSM-based backend deploy IAM + S3 are provisioned."
  value       = var.enable_backend_ssm_deploy
}

output "backend_deploy_bucket" {
  description = "S3 bucket for GitHub Actions JAR uploads."
  value       = try(module.backend_deploy_artifacts[0].bucket_name, null)
}

output "backend_deploy_object_key" {
  description = "S3 object key for the deploy JAR."
  value       = try(module.backend_deploy_artifacts[0].deploy_object_key, null)
}

output "backend_deploy_role_arn" {
  description = "GitHub Actions OIDC role ARN — set as secret AWS_BACKEND_DEPLOY_ROLE_ARN."
  value       = try(module.ci_backend_deploy[0].deploy_role_arn, null)
}

output "backend_deploy_github_setup" {
  description = "GitHub repository variables/secrets for deploy.yml after apply."
  value = var.enable_backend_ssm_deploy ? {
    secret_AWS_BACKEND_DEPLOY_ROLE_ARN = module.ci_backend_deploy[0].deploy_role_arn
    variable_DEPLOY_BUCKET             = module.backend_deploy_artifacts[0].bucket_name
    variable_EC2_INSTANCE_ID           = module.ec2.instance_id
    variable_EC2_HOST                  = module.ec2.public_ip
    variable_APP_PATH                  = module.ec2.app_path
    variable_AWS_REGION                = var.aws_region
    terraform_managed_github_config    = length(module.github_backend_deploy_config) > 0
  } : null
}


# ------------------------------------------------------------------------------
# Product media CDN (S3 + CloudFront)
# ------------------------------------------------------------------------------

output "product_media_enabled" {
  description = "Whether product media CDN is provisioned."
  value       = var.enable_product_media_cdn
}

output "product_media_bucket" {
  description = "S3 bucket for product images."
  value       = try(module.product_media_cdn[0].bucket_id, null)
}

output "product_media_cdn_domain" {
  description = "CloudFront domain for product image URLs."
  value       = try(module.product_media_cdn[0].distribution_domain_name, null)
}

output "product_media_public_base_url" {
  description = "Set APP_STORAGE_S3_PUBLIC_BASE_URL on EC2."
  value       = try(module.product_media_cdn[0].public_base_url, null)
}

output "product_media_ec2_env_hint" {
  description = "S3 settings for /opt/gamya-couture/config/application.env on EC2."
  value       = try(module.product_media_cdn[0].ec2_env_hint, null)
}

output "product_media_vercel_env_hint" {
  description = "Vercel env for next/image (NEXT_PUBLIC_IMAGE_CDN_HOST)."
  value       = try(module.product_media_cdn[0].vercel_env_hint, null)
}

output "product_media_ec2_upload_policy_arn" {
  description = "IAM policy attached to EC2 for S3 media uploads."
  value       = try(module.product_media_cdn[0].ec2_upload_policy_arn, null)
}

# ------------------------------------------------------------------------------
# Consolidated summary — mirrors terraform plan modules/resources
# ------------------------------------------------------------------------------

output "provisioned_resources" {
  description = "All provisioned resources grouped by module (post-apply summary)."
  value = {
    environment = {
      name   = var.environment
      region = var.aws_region
      prefix = local.name_prefix
    }

    networking = {
      vpc_id              = module.vpc.vpc_id
      vpc_cidr            = module.vpc.vpc_cidr_block
      public_subnet_id    = module.vpc.public_subnet_id
      private_subnet_ids  = module.vpc.private_subnet_ids
      internet_gateway_id = module.vpc.internet_gateway_id
      availability_zones  = module.vpc.availability_zones
    }

    security_groups = {
      ec2_sg_id  = module.security_groups.security_group_id
      ec2_sg_arn = module.security_groups.security_group_arn
      rds_sg_id  = module.security_groups.rds_security_group_id
      rds_sg_arn = module.security_groups.rds_security_group_arn
    }

    ec2 = {
      instance_id   = module.ec2.instance_id
      instance_arn  = module.ec2.instance_arn
      instance_type = var.ec2_instance_type
      private_ip    = module.ec2.private_ip
      public_ip     = module.ec2.public_ip
      api_url       = module.ec2.api_url
      health_url    = module.ec2.health_url
    }

    rds = {
      instance_id        = module.rds.db_instance_id
      instance_arn       = module.rds.db_instance_arn
      subnet_group_name  = module.rds.db_subnet_group_name
      endpoint           = module.rds.db_endpoint
      port               = module.rds.db_port
      database_name      = module.rds.db_name
      username           = module.rds.db_username
      jdbc_url           = module.rds.jdbc_url
      ssm_username_path  = module.rds.ssm_parameter_username_name
      ssm_password_path  = module.rds.ssm_parameter_password_name
      secrets_policy_arn = module.rds.db_secrets_read_policy_arn
    }

    scheduler = var.enable_cost_schedule ? {
      enabled         = true
      timezone        = module.scheduler[0].timezone
      summary         = module.scheduler[0].schedule_summary
      stop_rules      = module.scheduler[0].stop_schedules
      start_rules     = module.scheduler[0].start_schedules
      lambda_name     = module.scheduler[0].lambda_function_name
      lambda_arn      = module.scheduler[0].lambda_function_arn
      stop_schedules  = module.scheduler[0].stop_schedule_arns
      start_schedules = module.scheduler[0].start_schedule_arns
      schedules_ec2   = module.scheduler[0].schedule_ec2
      schedules_rds   = module.scheduler[0].schedule_rds
      } : {
      enabled = false
    }

    spring_boot = {
      datasource_url      = module.rds.jdbc_url
      ssm_username_path   = module.rds.ssm_parameter_username_name
      ssm_password_path   = module.rds.ssm_parameter_password_name
      example_application = "modules/rds/examples/application-prod.yml"
    }
  }
}
