output "ec2_security_group_id" {
  description = "Security group ID for the EC2 application instance."
  value       = aws_security_group.ec2.id
}

output "ec2_security_group_arn" {
  description = "ARN of the EC2 application security group."
  value       = aws_security_group.ec2.arn
}

output "rds_security_group_id" {
  description = "Security group ID for RDS PostgreSQL."
  value       = aws_security_group.rds.id
}

output "rds_security_group_arn" {
  description = "ARN of the RDS security group."
  value       = aws_security_group.rds.arn
}
