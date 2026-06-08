output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "Public subnet ID."
  value       = module.vpc.public_subnet_id
}

output "security_group_id" {
  description = "API security group ID."
  value       = module.security_groups.security_group_id
}

output "ec2_instance_id" {
  description = "API EC2 instance ID."
  value       = module.ec2.instance_id
}

output "api_public_ip" {
  description = "Elastic IP — point DNS or use in Vercel env vars."
  value       = module.ec2.public_ip
}

output "api_url" {
  description = "HTTP API base URL."
  value       = module.ec2.api_url
}

output "health_url" {
  description = "Health check URL."
  value       = module.ec2.health_url
}

output "vercel_env_hint" {
  description = "Set in Vercel project environment variables."
  value       = "NEXT_PUBLIC_API_URL=${module.ec2.api_url}"
}
