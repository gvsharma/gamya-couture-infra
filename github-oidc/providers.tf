provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "gamya-couture"
      ManagedBy   = "terraform"
      Environment = "shared"
      Purpose     = "github-actions-oidc"
    }
  }
}
