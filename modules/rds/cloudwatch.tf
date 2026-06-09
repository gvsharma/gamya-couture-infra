# Pre-created only when log exports are enabled (empty groups incur no ingest cost).
resource "aws_cloudwatch_log_group" "postgresql" {
  count = var.enable_cloudwatch_logs_exports ? 1 : 0

  name              = local.postgresql_log_group
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.name_prefix}-rds-postgresql-logs"
  }
}

resource "aws_cloudwatch_log_group" "upgrade" {
  count = var.enable_cloudwatch_logs_exports ? 1 : 0

  name              = local.upgrade_log_group
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.name_prefix}-rds-upgrade-logs"
  }
}
