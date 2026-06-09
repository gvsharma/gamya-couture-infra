terraform {
  backend "s3" {
    bucket         = "gamya-couture-terraform-state"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1" # state bucket lives here; resources use ap-south-1 via provider
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
