output "role_arn" {
  description = "IAM role ARN for GitHub Actions Terraform workflows."
  value       = aws_iam_role.terraform.arn
}

output "role_name" {
  description = "IAM role name."
  value       = aws_iam_role.terraform.name
}

output "oidc_provider_arn" {
  description = "GitHub OIDC provider ARN."
  value       = local.oidc_provider_arn
}
