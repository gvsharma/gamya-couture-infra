resource "aws_instance" "api" {
  ami                    = coalesce(var.ami_id, data.aws_ami.al2023.id)
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = aws_iam_instance_profile.api.name
  key_name               = var.key_name

  user_data                   = local.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

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
    Name            = "${var.name_prefix}-api"
    Role            = "vercel-backend"
    ResourcePurpose = "compute-api-backend-ec2"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_eip" "api" {
  domain = "vpc"

  tags = {
    Name            = "${var.name_prefix}-api-eip"
    ResourcePurpose = "network-elastic-ip-api"
  }
}

resource "aws_eip_association" "api" {
  instance_id   = aws_instance.api.id
  allocation_id = aws_eip.api.id
}
