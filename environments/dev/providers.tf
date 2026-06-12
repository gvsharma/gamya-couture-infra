terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = module.tags.common_tags
  }
}

provider "github" {
  owner = split("/", var.github_backend_repository)[0]
  token = coalesce(var.github_token, "")
}

module "tags" {
  source = "../../global"

  environment       = var.environment
  project           = var.project
  owner             = var.owner
  cost_optimization = var.cost_optimization
  auto_shutdown     = var.enable_cost_schedule ? "true" : "false"
}
