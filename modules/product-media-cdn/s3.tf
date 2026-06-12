resource "aws_s3_bucket" "media" {
  count = var.manage_bucket ? 1 : 0

  bucket        = var.bucket_name
  force_destroy = var.force_destroy_bucket

  tags = {
    Name            = "${var.name_prefix}-product-media"
    ResourcePurpose = "s3-product-images"
  }
}

data "aws_s3_bucket" "existing" {
  count  = var.manage_bucket ? 0 : 1
  bucket = var.bucket_name
}

locals {
  bucket_id                    = var.manage_bucket ? aws_s3_bucket.media[0].id : data.aws_s3_bucket.existing[0].id
  bucket_arn                   = var.manage_bucket ? aws_s3_bucket.media[0].arn : data.aws_s3_bucket.existing[0].arn
  bucket_regional_domain_name  = var.manage_bucket ? aws_s3_bucket.media[0].bucket_regional_domain_name : data.aws_s3_bucket.existing[0].bucket_regional_domain_name
  normalized_object_key_prefix = trimsuffix(var.object_key_prefix, "/")
  object_key_prefix_with_slash = "${local.normalized_object_key_prefix}/"
}

resource "aws_s3_bucket_public_access_block" "media" {
  count = var.manage_bucket ? 1 : 0

  bucket = aws_s3_bucket.media[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "media" {
  count = var.manage_bucket ? 1 : 0

  bucket = aws_s3_bucket.media[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "media" {
  count = var.manage_bucket ? 1 : 0

  bucket = aws_s3_bucket.media[0].id

  versioning_configuration {
    status = "Enabled"
  }
}
