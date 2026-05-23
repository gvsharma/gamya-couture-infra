# Pre-create log groups so retention is enforced from day one.
resource "aws_cloudwatch_log_group" "postgresql" {
  name              = local.postgresql_log_group
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.name_prefix}-rds-postgresql-logs"
  }
}

resource "aws_cloudwatch_log_group" "upgrade" {
  name              = local.upgrade_log_group
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.name_prefix}-rds-upgrade-logs"
  }
}
