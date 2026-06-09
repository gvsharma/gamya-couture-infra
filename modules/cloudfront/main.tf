resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.comment} (${var.name_prefix})"
  default_root_object = var.default_root_object
  price_class         = var.price_class
  http_version        = "http2and3"
  wait_for_deployment = false

  aliases = local.use_custom_domain ? var.aliases : []

  origin {
    domain_name              = var.frontend_bucket_regional_domain_name
    origin_id                = "frontend"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  origin {
    domain_name              = var.images_bucket_regional_domain_name
    origin_id                = "images"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  origin {
    domain_name              = var.videos_bucket_regional_domain_name
    origin_id                = "videos"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  default_cache_behavior {
    target_origin_id       = "frontend"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    cache_policy_id = local.cache_policy_caching_optimized
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.enable_media_behaviors ? [1] : []

    content {
      path_pattern           = "/images/*"
      target_origin_id       = "images"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      compress               = true

      cache_policy_id            = local.cache_policy_caching_optimized
      origin_request_policy_id   = local.media_origin_request_policy_id
      response_headers_policy_id = local.response_headers_policy_cors
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.enable_media_behaviors ? [1] : []

    content {
      path_pattern           = "/videos/*"
      target_origin_id       = "videos"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      compress               = true

      cache_policy_id          = local.cache_policy_caching_optimized
      origin_request_policy_id = local.origin_request_policy_cors_s3
    }
  }

  dynamic "custom_error_response" {
    for_each = var.enable_spa_fallback ? [403, 404] : []

    content {
      error_code         = custom_error_response.value
      response_code      = 200
      response_page_path = "/${var.default_root_object}"
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = local.use_custom_domain ? false : true
    acm_certificate_arn            = local.use_custom_domain ? var.acm_certificate_arn : null
    ssl_support_method             = local.use_custom_domain ? "sni-only" : null
    minimum_protocol_version       = local.use_custom_domain ? "TLSv1.2_2021" : null
  }

  tags = {
    Name = "${var.name_prefix}-cdn"
  }
}
