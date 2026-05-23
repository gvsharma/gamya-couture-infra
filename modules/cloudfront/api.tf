resource "aws_cloudfront_distribution" "api" {
  count = local.use_custom_domain && var.enable_api_distribution ? 1 : 0

  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.comment} API (${var.name_prefix})"
  price_class     = var.price_class
  http_version    = "http2and3"
  aliases         = var.api_aliases

  origin {
    domain_name = var.api_origin_hostname
    origin_id   = "ec2-api"

    custom_origin_config {
      http_port              = var.api_origin_http_port
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "ec2-api"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    cache_policy_id            = local.cache_policy_caching_disabled
    origin_request_policy_id   = local.origin_request_policy_all_viewer
    response_headers_policy_id = local.response_headers_policy_cors
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "${var.name_prefix}-cdn-api"
  }
}
