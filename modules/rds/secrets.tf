resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"

  keepers = {
    rotation = var.password_rotation_trigger
  }
}

resource "aws_ssm_parameter" "db_username" {
  name        = "${var.parameter_store_prefix}/username"
  description = "Gamya Couture RDS master username (${var.name_prefix})."
  type        = "SecureString"
  value       = var.db_username

  tags = {
    Name            = "${var.name_prefix}-db-username"
    ResourcePurpose = "secrets-db-username-ssm"
  }
}

resource "aws_ssm_parameter" "db_password" {
  name        = "${var.parameter_store_prefix}/password"
  description = "Gamya Couture RDS master password (${var.name_prefix})."
  type        = "SecureString"
  value       = random_password.master.result

  tags = {
    Name            = "${var.name_prefix}-db-password"
    ResourcePurpose = "secrets-db-password-ssm"
  }

  lifecycle {
    ignore_changes = [value]
  }
}

data "aws_iam_policy_document" "read_db_secrets" {
  count = var.create_db_secrets_read_policy ? 1 : 0

  statement {
    sid    = "ReadDbParameters"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
    resources = [
      aws_ssm_parameter.db_username.arn,
      aws_ssm_parameter.db_password.arn,
    ]
  }

  statement {
    sid    = "DecryptDbParameters"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ssm.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

data "aws_region" "current" {}

resource "aws_iam_policy" "read_db_secrets" {
  count = var.create_db_secrets_read_policy ? 1 : 0

  name_prefix = "${var.name_prefix}-rds-secrets-"
  description = "Read RDS credentials from SSM Parameter Store (${var.name_prefix})."
  policy      = data.aws_iam_policy_document.read_db_secrets[0].json

  tags = {
    Name            = "${var.name_prefix}-rds-secrets-read"
    ResourcePurpose = "iam-rds-secrets-read"
  }
}
