# Remote state for environments/prod
# Usage: terraform init -backend-config=../../bootstrap/examples/backend.prod.hcl

bucket         = "gamya-couture-terraform-state"
key            = "infra/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-locks"
