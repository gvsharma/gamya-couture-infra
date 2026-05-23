# Remote state — run bootstrap first, then:
#   terraform init -backend-config=../../bootstrap/examples/backend.prod.hcl
terraform {
  backend "s3" {}
}
