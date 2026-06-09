# Non-sensitive defaults for GitHub Actions — DEV ONLY
# Override admin_cidr via repository variable: TF_VAR_admin_cidr

aws_region  = "ap-south-1"
environment = "dev"
project     = "gamya-couture"

vpc_cidr = "10.50.0.0/16"

enable_ssh   = true
admin_cidr   = "127.0.0.1/32"

ec2_instance_type = "t3.micro"
api_port          = 8080
