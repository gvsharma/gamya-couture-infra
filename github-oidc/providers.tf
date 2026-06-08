provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "gamya-couture"
      ManagedBy   = "terraform"
      Environment = "dev"
      Purpose     = "github-actions-oidc-dev"
    }
  }
}
