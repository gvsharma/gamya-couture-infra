output "bucket_id" {
  description = "Product images S3 bucket name."
  value       = local.bucket_id
}

output "bucket_arn" {
  description = "Product images S3 bucket ARN."
  value       = local.bucket_arn
}

output "distribution_id" {
  description = "CloudFront distribution ID."
  value       = aws_cloudfront_distribution.media.id
}

output "distribution_domain_name" {
  description = "CloudFront domain for product image URLs."
  value       = aws_cloudfront_distribution.media.domain_name
}

output "public_base_url" {
  description = "HTTPS base URL for APP_STORAGE_S3_PUBLIC_BASE_URL (no trailing slash)."
  value       = "https://${aws_cloudfront_distribution.media.domain_name}"
}

output "image_cdn_host" {
  description = "Hostname for NEXT_PUBLIC_IMAGE_CDN_HOST."
  value       = aws_cloudfront_distribution.media.domain_name
}

output "ec2_upload_policy_arn" {
  description = "IAM policy for EC2 media uploads (attach to instance role)."
  value       = aws_iam_policy.ec2_media_upload.arn
}

output "cache_invalidation_command" {
  description = "Invalidate CloudFront after bulk image changes."
  value       = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.media.id} --paths '/${local.normalized_object_key_prefix}/*'"
}

output "ec2_env_hint" {
  description = "Spring Boot / application.env S3 settings."
  value = {
    APP_STORAGE_S3_ENABLED         = "true"
    APP_STORAGE_S3_BUCKET          = local.bucket_id
    APP_STORAGE_S3_REGION          = data.aws_region.current.name
    APP_STORAGE_S3_PUBLIC_BASE_URL = "https://${aws_cloudfront_distribution.media.domain_name}"
    APP_STORAGE_S3_KEY_PREFIX      = var.object_key_prefix
  }
}

output "vercel_env_hint" {
  description = "Vercel env for next/image remote patterns."
  value       = "NEXT_PUBLIC_IMAGE_CDN_HOST=${aws_cloudfront_distribution.media.domain_name}"
}
