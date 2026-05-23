resource "aws_cloudwatch_log_group" "nginx_access" {
  name              = local.log_group_nginx_access
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.name_prefix}-nginx-access"
  }
}

resource "aws_cloudwatch_log_group" "nginx_error" {
  name              = local.log_group_nginx_error
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.name_prefix}-nginx-error"
  }
}

resource "aws_cloudwatch_log_group" "app" {
  name              = local.log_group_app
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.name_prefix}-app"
  }
}

resource "aws_cloudwatch_log_group" "docker" {
  name              = local.log_group_docker
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.name_prefix}-docker"
  }
}
