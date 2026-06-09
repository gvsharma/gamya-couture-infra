output "frontend_bucket_id" {
  description = "Frontend static site bucket name."
  value       = aws_s3_bucket.frontend.id
}

output "frontend_bucket_arn" {
  description = "Frontend bucket ARN."
  value       = aws_s3_bucket.frontend.arn
}

output "frontend_bucket_regional_domain_name" {
  description = "Regional domain for CloudFront origin."
  value       = aws_s3_bucket.frontend.bucket_regional_domain_name
}

output "images_bucket_id" {
  description = "Product images bucket name."
  value       = aws_s3_bucket.images.id
}

output "images_bucket_arn" {
  description = "Product images bucket ARN."
  value       = aws_s3_bucket.images.arn
}

output "images_bucket_regional_domain_name" {
  description = "Regional domain for CloudFront images origin."
  value       = aws_s3_bucket.images.bucket_regional_domain_name
}

output "videos_bucket_id" {
  description = "Product videos bucket name."
  value       = aws_s3_bucket.videos.id
}

output "videos_bucket_arn" {
  description = "Product videos bucket ARN."
  value       = aws_s3_bucket.videos.arn
}

output "videos_bucket_regional_domain_name" {
  description = "Regional domain for CloudFront videos origin."
  value       = aws_s3_bucket.videos.bucket_regional_domain_name
}

output "ec2_media_upload_policy_arn" {
  description = "IAM policy for EC2 media uploads (attach to instance role)."
  value       = try(aws_iam_policy.ec2_media_upload[0].arn, null)
}
