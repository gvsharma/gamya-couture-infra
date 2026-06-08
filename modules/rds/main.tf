resource "aws_db_subnet_group" "this" {
  name_prefix = "${var.name_prefix}-db-"
  subnet_ids  = var.private_subnet_ids
  description = "Private subnets for ${var.name_prefix} PostgreSQL."

  tags = {
    Name = "${var.name_prefix}-db-subnet-group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "this" {
  identifier = local.db_identifier

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.db_username
  password = random_password.master.result

  allocated_storage = var.allocated_storage_gb
  storage_type      = var.storage_type
  storage_encrypted = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids

  publicly_accessible     = false
  multi_az                = false
  deletion_protection     = false
  backup_retention_period = 0
  skip_final_snapshot     = true
  copy_tags_to_snapshot   = false
  delete_automated_backups  = true
  auto_minor_version_upgrade   = true
  apply_immediately            = true

  # Cost: disable paid observability features
  performance_insights_enabled = false
  monitoring_interval          = 0

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = {
    Name = "${var.name_prefix}-postgres"
  }

  depends_on = [
    aws_cloudwatch_log_group.postgresql,
    aws_cloudwatch_log_group.upgrade,
  ]

  lifecycle {
    ignore_changes = [password]
  }
}
