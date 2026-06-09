output "distribution_id" {
  description = "CloudFront distribution ID."
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN (for S3 bucket policies)."
  value       = aws_cloudfront_distribution.this.arn
}

output "distribution_domain_name" {
  description = "CloudFront domain (e.g. d111111abcdef8.cloudfront.net)."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "distribution_hosted_zone_id" {
  description = "Route53 alias zone ID for CloudFront."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "origin_access_control_id" {
  description = "OAC ID used for S3 origins."
  value       = aws_cloudfront_origin_access_control.s3.id
}

output "frontend_url" {
  description = "HTTPS URL for the static site (default domain)."
  value       = "https://${aws_cloudfront_distribution.this.domain_name}"
}

output "images_cdn_path" {
  description = "Path prefix on this distribution for product images."
  value       = "https://${aws_cloudfront_distribution.this.domain_name}/images/"
}

output "videos_cdn_path" {
  description = "Path prefix on this distribution for product videos."
  value       = "https://${aws_cloudfront_distribution.this.domain_name}/videos/"
}

output "cache_invalidation_command" {
  description = "Example CLI to invalidate all paths after deploy."
  value       = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.this.id} --paths '/*'"
}

output "api_distribution_id" {
  description = "API/admin CloudFront distribution ID (null if disabled)."
  value       = try(aws_cloudfront_distribution.api[0].id, null)
}

output "api_distribution_domain_name" {
  description = "API CloudFront domain for Route53 alias records."
  value       = try(aws_cloudfront_distribution.api[0].domain_name, null)
}

output "api_distribution_hosted_zone_id" {
  description = "Route53 zone ID for API CloudFront alias."
  value       = try(aws_cloudfront_distribution.api[0].hosted_zone_id, null)
}
