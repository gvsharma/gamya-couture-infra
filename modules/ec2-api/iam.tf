data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "db_secrets" {
  count = var.db_parameter_store_prefix != "" ? 1 : 0

  statement {
    sid    = "ReadDbParameters"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.db_parameter_store_prefix}/username",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.db_parameter_store_prefix}/password",
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

resource "aws_iam_role" "api" {
  name_prefix        = "${var.name_prefix}-api-"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name            = "${var.name_prefix}-api-role"
    ResourcePurpose = "iam-ec2-api-role"
  }
}

resource "aws_iam_role_policy" "db_secrets" {
  count = var.db_parameter_store_prefix != "" ? 1 : 0

  name_prefix = "${var.name_prefix}-db-secrets-"
  role        = aws_iam_role.api.id
  policy      = data.aws_iam_policy_document.db_secrets[0].json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.api.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = toset(var.additional_iam_policy_arns)

  role       = aws_iam_role.api.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "api" {
  name_prefix = "${var.name_prefix}-api-"
  role        = aws_iam_role.api.name
}
