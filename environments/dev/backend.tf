terraform {
  backend "s3" {
    bucket         = "gamya-couture-terraform-state"
    key            = "infra/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
