# Remote state for environments/dev
# Usage: terraform init -backend-config=../../bootstrap/examples/backend.dev.hcl

bucket         = "gamya-couture-terraform-state"
key            = "infra/dev/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-locks"
