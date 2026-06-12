locals {
  name_prefix               = "${var.project}-${var.environment}"
  db_parameter_store_prefix = "/${var.project}/${var.environment}/db"
  rds_instance_identifier   = substr(replace("${local.name_prefix}-pg", "_", "-"), 0, 63)
}
