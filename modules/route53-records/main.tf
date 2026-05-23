# ------------------------------------------------------------------------------
# CloudFront — static site (apex + www)
# ------------------------------------------------------------------------------

resource "aws_route53_record" "apex_ipv4" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.web_cloudfront_domain_name
    zone_id                = var.web_cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "apex_ipv6" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = var.web_cloudfront_domain_name
    zone_id                = var.web_cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_ipv4" {
  zone_id = var.zone_id
  name    = var.www_fqdn
  type    = "A"

  alias {
    name                   = var.web_cloudfront_domain_name
    zone_id                = var.web_cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_ipv6" {
  zone_id = var.zone_id
  name    = var.www_fqdn
  type    = "AAAA"

  alias {
    name                   = var.web_cloudfront_domain_name
    zone_id                = var.web_cloudfront_zone_id
    evaluate_target_health = false
  }
}

# ------------------------------------------------------------------------------
# EC2 origin (direct — CloudFront connects here over HTTP)
# ------------------------------------------------------------------------------

resource "aws_route53_record" "origin_api_ipv4" {
  zone_id = var.zone_id
  name    = var.origin_api_fqdn
  type    = "A"
  ttl     = 300
  records = [var.ec2_public_ip]
}

# ------------------------------------------------------------------------------
# CloudFront — API + admin (HTTPS at edge)
# ------------------------------------------------------------------------------

resource "aws_route53_record" "api_ipv4" {
  zone_id = var.zone_id
  name    = var.api_fqdn
  type    = "A"

  alias {
    name                   = var.api_cloudfront_domain_name
    zone_id                = var.api_cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api_ipv6" {
  zone_id = var.zone_id
  name    = var.api_fqdn
  type    = "AAAA"

  alias {
    name                   = var.api_cloudfront_domain_name
    zone_id                = var.api_cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "admin_ipv4" {
  zone_id = var.zone_id
  name    = var.admin_fqdn
  type    = "A"

  alias {
    name                   = var.api_cloudfront_domain_name
    zone_id                = var.api_cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "admin_ipv6" {
  zone_id = var.zone_id
  name    = var.admin_fqdn
  type    = "AAAA"

  alias {
    name                   = var.api_cloudfront_domain_name
    zone_id                = var.api_cloudfront_zone_id
    evaluate_target_health = false
  }
}
