# Remote state for environments/dev
# Usage: terraform init -backend-config=../../bootstrap/examples/backend.dev.hcl

bucket         = "gamya-couture-tf-state"
key            = "dev/terraform.tfstate"
region         = "ap-south-1"
encrypt        = true
dynamodb_table = "gamya-couture-tf-locks"
