output "db_instance_id" {
  description = "RDS instance identifier."
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "RDS instance ARN."
  value       = aws_db_instance.this.arn
}

output "db_endpoint" {
  description = "Connection endpoint (hostname only)."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "PostgreSQL port."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Database name."
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "Master username (non-sensitive; also in Parameter Store)."
  value       = aws_db_instance.this.username
}

output "db_subnet_group_name" {
  description = "DB subnet group name."
  value       = aws_db_subnet_group.this.name
}

output "ssm_parameter_username_name" {
  description = "SSM parameter name for DB username."
  value       = aws_ssm_parameter.db_username.name
}

output "ssm_parameter_password_name" {
  description = "SSM parameter name for DB password."
  value       = aws_ssm_parameter.db_password.name
}

output "ssm_parameter_username_arn" {
  description = "SSM parameter ARN for DB username."
  value       = aws_ssm_parameter.db_username.arn
}

output "ssm_parameter_password_arn" {
  description = "SSM parameter ARN for DB password."
  value       = aws_ssm_parameter.db_password.arn
}

output "db_secrets_read_policy_arn" {
  description = "IAM policy ARN to attach to EC2 for reading DB credentials from SSM."
  value       = try(aws_iam_policy.read_db_secrets[0].arn, null)
}

output "jdbc_url" {
  description = "JDBC URL template (password from SSM)."
  value       = "jdbc:postgresql://${aws_db_instance.this.address}:${aws_db_instance.this.port}/${aws_db_instance.this.db_name}"
  sensitive   = false
}
