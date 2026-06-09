resource "aws_iam_role" "api" {
  name_prefix        = "${var.name_prefix}-api-"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name            = "${var.name_prefix}-api-role"
    ResourcePurpose = "iam-ec2-api-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.api.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "additional" {
  count = length(var.additional_iam_policy_arns)

  role       = aws_iam_role.api.name
  policy_arn = var.additional_iam_policy_arns[count.index]
}

resource "aws_iam_instance_profile" "api" {
  name_prefix = "${var.name_prefix}-api-"
  role        = aws_iam_role.api.name
}
