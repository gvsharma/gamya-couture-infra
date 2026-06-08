# Remote state for environments/api
# Usage: terraform init -backend-config=../../bootstrap/examples/backend.api.hcl

bucket         = "gamya-couture-terraform-state"
key            = "infra/api/terraform.tfstate"
region         = "ap-south-1"
encrypt        = true
dynamodb_table = "terraform-locks"
