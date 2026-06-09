output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.api.id
}

output "instance_arn" {
  description = "EC2 instance ARN (for scheduler IAM scoping)."
  value       = aws_instance.api.arn
}

output "private_ip" {
  description = "Private IP."
  value       = aws_instance.api.private_ip
}

output "public_ip" {
  description = "Elastic IP for Vercel / DNS A record."
  value       = aws_eip.api.public_ip
}

output "api_url" {
  description = "HTTP base URL for the API."
  value       = "http://${aws_eip.api.public_ip}"
}

output "health_url" {
  description = "Health check endpoint."
  value       = "http://${aws_eip.api.public_ip}/health"
}

output "iam_role_arn" {
  description = "EC2 instance IAM role ARN."
  value       = aws_iam_role.api.arn
}

output "iam_role_name" {
  description = "EC2 instance IAM role name."
  value       = aws_iam_role.api.name
}

output "app_path" {
  description = "Application root path on the instance."
  value       = var.app_path
}
