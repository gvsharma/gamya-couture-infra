module "github_terraform" {
  count  = var.enable_github_actions ? 1 : 0
  source = "../modules/ci-terraform-iam"

  name_prefix          = var.project
  github_repository    = var.github_repository
  state_bucket_arn     = aws_s3_bucket.terraform_state.arn
  lock_table_arn       = aws_dynamodb_table.terraform_locks.arn
  create_oidc_provider = var.create_github_oidc_provider
}
