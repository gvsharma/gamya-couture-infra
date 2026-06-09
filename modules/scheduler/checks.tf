check "scheduler_has_target" {
  assert {
    condition     = !var.enabled || local.schedule_rds || local.schedule_ec2
    error_message = "When scheduler is enabled, set db_instance_identifier and/or ec2_instance_id."
  }
}

check "scheduler_rds_arn" {
  assert {
    condition     = !local.schedule_rds || var.db_instance_arn != ""
    error_message = "db_instance_arn is required when db_instance_identifier is set."
  }
}

check "scheduler_ec2_arn" {
  assert {
    condition     = !local.schedule_ec2 || var.ec2_instance_arn != ""
    error_message = "ec2_instance_arn is required when ec2_instance_id is set."
  }
}
