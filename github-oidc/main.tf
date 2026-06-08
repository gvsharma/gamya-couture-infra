module "github_terraform" {
  source = "../modules/ci-terraform-iam"

  aws_account_id              = var.aws_account_id
  github_repository           = var.github_repository
  role_name                   = var.role_name
  create_oidc_provider        = var.create_oidc_provider
  attach_administrator_access = var.attach_administrator_access

  oidc_subjects = [
    "repo:${var.github_repository}:*",
  ]
}
