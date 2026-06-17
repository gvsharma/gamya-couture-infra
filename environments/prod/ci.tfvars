# Non-sensitive defaults for GitHub Actions (terraform plan/apply).
# Override via GitHub repository variables: Settings → Secrets and variables → Actions → Variables
#   TF_VAR_domain_name = gamyacouture.com

aws_region  = "ap-south-1"
environment = "prod"
project     = "gamya-couture"
owner       = "Venkat"

enable_ssh = false
admin_cidr = "127.0.0.1/32"

restrict_web_ingress_to_cloudfront = true

domain_name     = ""
api_subdomain   = "api"
www_subdomain   = "www"
admin_subdomain = "admin"

db_name     = "gamya"
db_username = "gamya_admin"

ec2_instance_type = "t4g.micro"

# Cost scheduler: Mon–Fri 06:00–11:00; Sat 18:00–00:00; Sun 06:00–00:00 IST (EC2 + RDS)
enable_cost_schedule = true
schedule_timezone  = "Asia/Kolkata"
