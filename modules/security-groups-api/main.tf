resource "aws_security_group" "api" {
  name_prefix = "${var.name_prefix}-api-"
  description = "Gamya Couture API EC2 - HTTP/HTTPS public, SSH restricted."
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}-api-sg"
    Tier = "app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each = toset(var.http_https_cidr_blocks)

  security_group_id = aws_security_group.api.id
  description       = "HTTP from ${each.value}"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each = toset(var.http_https_cidr_blocks)

  security_group_id = aws_security_group.api.id
  description       = "HTTPS from ${each.value}"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "ssh_admin" {
  count = var.enable_ssh ? 1 : 0

  security_group_id = aws_security_group.api.id
  description       = "SSH from admin IP only"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.admin_cidr
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.api.id
  description       = "Outbound for updates and external APIs"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
