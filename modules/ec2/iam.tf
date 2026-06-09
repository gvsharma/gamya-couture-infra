resource "aws_iam_role" "ec2" {
  name_prefix = "${var.name_prefix}-ec2-"
  description = "IAM role for Gamya Couture application EC2 (SSM + CloudWatch)."
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${var.name_prefix}-ec2-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy" "cloudwatch_logs" {
  name_prefix = "${var.name_prefix}-cw-logs-"
  role        = aws_iam_role.ec2.id
  policy      = data.aws_iam_policy_document.cloudwatch_logs.json
}

resource "aws_iam_role_policy_attachment" "additional" {
  count = length(var.additional_iam_policy_arns)

  role       = aws_iam_role.ec2.name
  policy_arn = var.additional_iam_policy_arns[count.index]
}

resource "aws_iam_instance_profile" "ec2" {
  name_prefix = "${var.name_prefix}-ec2-"
  role        = aws_iam_role.ec2.name

  tags = {
    Name = "${var.name_prefix}-ec2-profile"
  }
}
