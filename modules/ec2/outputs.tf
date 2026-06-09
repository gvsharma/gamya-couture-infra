output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.app.id
}

output "instance_arn" {
  description = "EC2 instance ARN."
  value       = aws_instance.app.arn
}

output "private_ip" {
  description = "Private IPv4 address."
  value       = aws_instance.app.private_ip
}

output "public_ip" {
  description = "Elastic IP address (stable public endpoint)."
  value       = aws_eip.app.public_ip
}

output "elastic_ip_allocation_id" {
  description = "Elastic IP allocation ID."
  value       = aws_eip.app.id
}

output "iam_role_name" {
  description = "IAM role name attached to the instance."
  value       = aws_iam_role.ec2.name
}

output "iam_role_arn" {
  description = "IAM role ARN."
  value       = aws_iam_role.ec2.arn
}

output "iam_instance_profile_arn" {
  description = "Instance profile ARN."
  value       = aws_iam_instance_profile.ec2.arn
}

output "cloudwatch_log_group_names" {
  description = "CloudWatch log groups for the CloudWatch agent."
  value = {
    nginx_access = aws_cloudwatch_log_group.nginx_access.name
    nginx_error  = aws_cloudwatch_log_group.nginx_error.name
    app          = aws_cloudwatch_log_group.app.name
    docker       = aws_cloudwatch_log_group.docker.name
  }
}

output "deployment_paths" {
  description = "Standard deployment directories on the host."
  value = {
    base    = "/opt/gamya-couture"
    app     = "/opt/gamya-couture/app"
    config  = "/opt/gamya-couture/config"
    logs    = "/opt/gamya-couture/logs"
    data    = "/opt/gamya-couture/data"
    compose = "/opt/gamya-couture/app/docker-compose.yml"
  }
}
