data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  schedule_rds = var.schedule_rds
  schedule_ec2 = var.schedule_ec2

  rds_instance_arn = var.schedule_rds ? "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:db:${var.db_instance_identifier}" : null
  ec2_instance_arn = var.schedule_ec2 ? "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/${var.ec2_instance_id}" : null

  # Default IST schedule (Asia/Kolkata):
  #   Mon–Fri: running 06:00–11:00 only
  #   Sat:     running 18:00–00:00
  #   Sun:     running 06:00–00:00
  default_start_schedules = {
    weekday_morning = {
      expression  = "cron(0 6 ? * MON-FRI *)"
      description = "Mon–Fri 06:00"
    }
    saturday_evening = {
      expression  = "cron(0 18 ? * SAT *)"
      description = "Sat 18:00"
    }
    sunday_morning = {
      expression  = "cron(0 6 ? * SUN *)"
      description = "Sun 06:00"
    }
  }

  default_stop_schedules = {
    weekday_morning = {
      expression  = "cron(0 11 ? * MON-FRI *)"
      description = "Mon–Fri 11:00"
    }
    sunday_midnight = {
      expression  = "cron(0 0 ? * SUN *)"
      description = "Sun 00:00 (end Sat evening window)"
    }
    monday_midnight = {
      expression  = "cron(0 0 ? * MON *)"
      description = "Mon 00:00 (end Sun window)"
    }
  }

  start_schedules = length(var.start_schedules) > 0 ? var.start_schedules : local.default_start_schedules
  stop_schedules  = length(var.stop_schedules) > 0 ? var.stop_schedules : local.default_stop_schedules
}
