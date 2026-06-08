output "role_arn" {
  description = "Set as GitHub repository secret AWS_ROLE_ARN."
  value       = module.github_terraform.role_arn
}

output "role_name" {
  value = module.github_terraform.role_name
}

output "oidc_provider_arn" {
  value = module.github_terraform.oidc_provider_arn
}

output "aws_account_id" {
  value = module.github_terraform.aws_account_id
}
