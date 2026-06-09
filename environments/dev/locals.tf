locals {
  name_prefix               = "${var.project}-${var.environment}"
  db_parameter_store_prefix = "/${var.project}/${var.environment}/db"
}
