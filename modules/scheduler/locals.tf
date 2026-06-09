locals {
  schedule_rds = var.db_instance_identifier != ""
  schedule_ec2 = var.ec2_instance_id != ""
}
