resource "aws_cloudfront_origin_access_control" "media" {
  name                              = "${var.name_prefix}-media-oac"
  description                       = "OAC for ${var.name_prefix} product images bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "media" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.comment} (${var.name_prefix})"
  price_class         = var.price_class
  http_version        = "http2and3"
  wait_for_deployment = false

  origin {
    domain_name              = local.bucket_regional_domain_name
    origin_id                = "product-media"
    origin_access_control_id = aws_cloudfront_origin_access_control.media.id
  }

  default_cache_behavior {
    target_origin_id       = "product-media"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name            = "${var.name_prefix}-product-media-cdn"
    ResourcePurpose = "cloudfront-product-images"
  }
}

data "aws_iam_policy_document" "media_cloudfront_read" {
  statement {
    sid    = "AllowCloudFrontRead"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${local.bucket_arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.media.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "media" {
  bucket = local.bucket_id
  policy = data.aws_iam_policy_document.media_cloudfront_read.json
}
