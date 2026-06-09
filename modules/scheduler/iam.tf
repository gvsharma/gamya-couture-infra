data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "scheduler_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_rds" {
  count = local.schedule_rds ? 1 : 0

  statement {
    sid    = "DescribeTargetInstance"
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
    ]
    resources = [var.db_instance_arn]
  }

  statement {
    sid    = "StopStartInstance"
    effect = "Allow"
    actions = [
      "rds:StopDBInstance",
      "rds:StartDBInstance",
    ]
    resources = [var.db_instance_arn]
  }
}

data "aws_iam_policy_document" "lambda_ec2" {
  count = local.schedule_ec2 ? 1 : 0

  statement {
    sid    = "DescribeTargetInstance"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
    ]
    resources = [var.ec2_instance_arn]
  }

  statement {
    sid    = "StopStartInstance"
    effect = "Allow"
    actions = [
      "ec2:StopInstances",
      "ec2:StartInstances",
    ]
    resources = [var.ec2_instance_arn]
  }
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    sid    = "WriteLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.lambda.arn}:*"]
  }
}

data "aws_iam_policy_document" "scheduler_invoke" {
  statement {
    sid    = "InvokeSchedulerLambda"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [aws_lambda_function.cost_scheduler.arn]
  }
}

resource "aws_iam_role" "lambda" {
  name_prefix        = "${var.name_prefix}-cost-sched-"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json

  tags = {
    Name             = "${var.name_prefix}-cost-scheduler-lambda-role"
    ResourcePurpose  = "cost-scheduler-lambda-iam"
  }
}

resource "aws_iam_role_policy" "lambda_rds" {
  count = local.schedule_rds ? 1 : 0

  name_prefix = "${var.name_prefix}-rds-"
  role        = aws_iam_role.lambda.id
  policy      = data.aws_iam_policy_document.lambda_rds[0].json
}

resource "aws_iam_role_policy" "lambda_ec2" {
  count = local.schedule_ec2 ? 1 : 0

  name_prefix = "${var.name_prefix}-ec2-"
  role        = aws_iam_role.lambda.id
  policy      = data.aws_iam_policy_document.lambda_ec2[0].json
}

resource "aws_iam_role_policy" "lambda_logging" {
  name_prefix = "${var.name_prefix}-logs-"
  role        = aws_iam_role.lambda.id
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role" "scheduler" {
  name_prefix        = "${var.name_prefix}-cost-sch-"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume.json

  tags = {
    Name            = "${var.name_prefix}-cost-scheduler-invoke-role"
    ResourcePurpose = "cost-scheduler-eventbridge-iam"
  }
}

resource "aws_iam_role_policy" "scheduler_invoke" {
  name_prefix = "${var.name_prefix}-invoke-"
  role        = aws_iam_role.scheduler.id
  policy      = data.aws_iam_policy_document.scheduler_invoke.json
}
