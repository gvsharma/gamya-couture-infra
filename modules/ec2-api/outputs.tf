output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.api.id
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
