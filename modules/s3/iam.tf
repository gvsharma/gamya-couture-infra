data "aws_iam_policy_document" "ec2_media_upload" {
  count = var.create_ec2_media_upload_policy ? 1 : 0

  statement {
    sid    = "ListMediaBuckets"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.images.arn,
      aws_s3_bucket.videos.arn,
    ]
  }

  statement {
    sid    = "ReadWriteMediaObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      "${aws_s3_bucket.images.arn}/*",
      "${aws_s3_bucket.videos.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "ec2_media_upload" {
  count = var.create_ec2_media_upload_policy ? 1 : 0

  name_prefix = "${var.name_prefix}-s3-media-"
  description = "Upload product images/videos from EC2 (${var.name_prefix})."
  policy      = data.aws_iam_policy_document.ec2_media_upload[0].json
}
