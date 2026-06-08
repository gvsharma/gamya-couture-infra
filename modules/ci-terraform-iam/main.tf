locals {
  github_oidc_url       = "https://token.actions.githubusercontent.com"
  oidc_subject_suffixes = length(var.allowed_ref_subjects) > 0 ? var.allowed_ref_subjects : var.default_allowed_subjects
  oidc_subjects         = [for suffix in local.oidc_subject_suffixes : "repo:${var.github_repository}:${suffix}"]
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url             = local.github_oidc_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.github_oidc_thumbprint]
}

data "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 0 : 1

  url = local.github_oidc_url
}

locals {
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(local.github_oidc_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${replace(local.github_oidc_url, "https://", "")}:sub"
      values   = local.oidc_subjects
    }
  }
}

resource "aws_iam_role" "terraform" {
  name_prefix        = "${var.name_prefix}-gh-tf-"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json

  tags = {
    Name = "${var.name_prefix}-github-terraform"
  }
}

data "aws_iam_policy_document" "terraform_state" {
  statement {
    sid    = "ListStateBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [var.state_bucket_arn]
  }

  statement {
    sid    = "ReadWriteStateObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${var.state_bucket_arn}/*"]
  }

  statement {
    sid    = "ManageStateLocks"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = [var.lock_table_arn]
  }
}

data "aws_iam_policy_document" "terraform_infra" {
  statement {
    sid    = "TerraformManagedServices"
    effect = "Allow"
    actions = [
      "acm:*",
      "cloudfront:*",
      "ec2:*",
      "events:*",
      "iam:*",
      "lambda:*",
      "logs:*",
      "rds:*",
      "route53:*",
      "s3:*",
      "scheduler:*",
      "ssm:*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ReadOnlyGlobal"
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "iam:Get*",
      "iam:List*",
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "terraform_state" {
  name_prefix = "${var.name_prefix}-gh-tf-state-"
  role        = aws_iam_role.terraform.id
  policy      = data.aws_iam_policy_document.terraform_state.json
}

resource "aws_iam_role_policy" "terraform_infra" {
  name_prefix = "${var.name_prefix}-gh-tf-infra-"
  role        = aws_iam_role.terraform.id
  policy      = data.aws_iam_policy_document.terraform_infra.json
}
