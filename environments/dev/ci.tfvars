# Non-sensitive defaults for GitHub Actions (terraform plan/apply).

aws_region  = "ap-south-1"
environment = "dev"
project     = "gamya-couture"

enable_ssh = false
admin_cidr = "127.0.0.1/32"

restrict_web_ingress_to_cloudfront = false

domain_name     = ""
api_subdomain   = "api-dev"
www_subdomain   = "dev"
admin_subdomain = "admin-dev"

db_name             = "gamya_dev"
db_username         = "gamya_admin"
enable_rds_schedule = false

ec2_instance_type = "t4g.micro"
