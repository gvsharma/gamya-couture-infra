locals {
  db_identifier = substr(replace("${var.name_prefix}-pg", "_", "-"), 0, 63)

  postgresql_log_group = "/aws/rds/instance/${local.db_identifier}/postgresql"
  upgrade_log_group    = "/aws/rds/instance/${local.db_identifier}/upgrade"
}
