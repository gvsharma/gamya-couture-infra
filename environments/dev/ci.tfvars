# Non-sensitive defaults for GitHub Actions — DEV ONLY
# Override admin_cidr via repository variable: TF_VAR_admin_cidr

aws_region  = "ap-south-1"
environment = "dev"
project     = "gamya-couture"
owner       = "Venkat"

vpc_cidr = "10.50.0.0/16"

enable_ssh = true
admin_cidr = "127.0.0.1/32"

ec2_instance_type = "t3.micro"
api_port          = 8080

# Backend deploy: S3 artifact bucket + GitHub OIDC → SSM Run Command (no SSH from runners)
enable_backend_ssm_deploy = true
github_backend_repository = "gvsharma/gamyaboutique"

# Cost scheduler: stop 00:00 IST, start 09:00 IST (EC2 + RDS)
enable_cost_schedule      = true
schedule_timezone         = "Asia/Kolkata"
schedule_stop_expression  = "cron(0 0 * * ? *)"
schedule_start_expression = "cron(0 9 * * ? *)"
