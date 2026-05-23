# Remote state — run bootstrap first, then:
#   terraform init -backend-config=../../bootstrap/examples/backend.dev.hcl
terraform {
  backend "s3" {}
}
