data "aws_region" "current" {}

data "aws_iam_policy_document" "ec2_media_upload" {
  statement {
    sid    = "UploadProductImages"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]
    resources = ["${local.bucket_arn}/${local.object_key_prefix_with_slash}*"]
  }

  statement {
    sid    = "ListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [local.bucket_arn]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["${local.object_key_prefix_with_slash}*"]
    }
  }
}

resource "aws_iam_policy" "ec2_media_upload" {
  name_prefix = "${var.name_prefix}-s3-media-"
  description = "Upload product images from EC2 (${var.name_prefix})."
  policy      = data.aws_iam_policy_document.ec2_media_upload.json
}
