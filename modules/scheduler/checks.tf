check "scheduler_has_target" {
  assert {
    condition     = !var.enabled || var.schedule_rds || var.schedule_ec2
    error_message = "When scheduler is enabled, set schedule_rds and/or schedule_ec2 to true."
  }
}

check "scheduler_rds_id" {
  assert {
    condition     = !var.schedule_rds || var.db_instance_identifier != ""
    error_message = "db_instance_identifier is required when schedule_rds is true."
  }
}

check "scheduler_ec2_id" {
  assert {
    condition     = !var.schedule_ec2 || var.ec2_instance_id != ""
    error_message = "ec2_instance_id is required when schedule_ec2 is true."
  }
}
