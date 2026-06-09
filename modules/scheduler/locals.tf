data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  schedule_rds = var.schedule_rds
  schedule_ec2 = var.schedule_ec2

  rds_instance_arn = var.schedule_rds ? "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:db:${var.db_instance_identifier}" : null
  ec2_instance_arn = var.schedule_ec2 ? "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/${var.ec2_instance_id}" : null
}
