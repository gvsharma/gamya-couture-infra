output "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "S3 bucket ARN."
  value       = aws_s3_bucket.terraform_state.arn
}

output "lock_table_name" {
  description = "DynamoDB table name for state locking."
  value       = aws_dynamodb_table.terraform_locks.name
}

output "lock_table_arn" {
  description = "DynamoDB table ARN."
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "terraform_state_iam_policy_arn" {
  description = "ARN of the least-privilege IAM policy (attach to your Terraform user/role)."
  value       = try(aws_iam_policy.terraform_state_access[0].arn, null)
}

output "backend_config_prod" {
  description = "Copy into environments/prod/backend.hcl after bootstrap."
  value = {
    bucket         = aws_s3_bucket.terraform_state.id
    key            = "prod/terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
  }
}

output "backend_config_dev" {
  description = "Copy into environments/dev/backend.hcl after bootstrap."
  value = {
    bucket         = aws_s3_bucket.terraform_state.id
    key            = "dev/terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
  }
}

output "github_terraform_role_arn" {
  description = "IAM role ARN — set as GitHub repository variable AWS_TERRAFORM_ROLE_ARN."
  value       = try(module.github_terraform[0].role_arn, null)
}
