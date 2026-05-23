# Remote state for environments/prod
# Usage: terraform init -backend-config=../../bootstrap/examples/backend.prod.hcl

bucket         = "gamya-couture-tf-state"
key            = "prod/terraform.tfstate"
region         = "ap-south-1"
encrypt        = true
dynamodb_table = "gamya-couture-tf-locks"
