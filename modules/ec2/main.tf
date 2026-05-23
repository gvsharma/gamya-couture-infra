resource "aws_instance" "app" {
  ami                    = coalesce(var.ami_id, data.aws_ami.al2023_arm.id)
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = aws_iam_instance_profile.ec2.name
  key_name               = var.key_name

  user_data                   = local.user_data
  user_data_replace_on_change = false

  monitoring                  = false
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size_gb
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name = "${var.name_prefix}-app"
    Role = "spring-boot"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_eip" "app" {
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-app-eip"
  }
}

resource "aws_eip_association" "app" {
  instance_id   = aws_instance.app.id
  allocation_id = aws_eip.app.id
}
