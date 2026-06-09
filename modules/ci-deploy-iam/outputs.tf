output "deploy_role_arn" {
  description = "IAM role ARN for GitHub Actions (aws-actions/configure-aws-credentials)."
  value       = aws_iam_role.github_deploy.arn
}

output "deploy_role_name" {
  description = "IAM role name for GitHub Actions."
  value       = aws_iam_role.github_deploy.name
}

output "oidc_provider_arn" {
  description = "GitHub OIDC provider ARN used for trust."
  value       = local.oidc_provider_arn
}
