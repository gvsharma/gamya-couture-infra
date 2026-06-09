output "security_group_id" {
  description = "API EC2 security group ID."
  value       = aws_security_group.api.id
}

output "security_group_arn" {
  description = "API EC2 security group ARN."
  value       = aws_security_group.api.arn
}
