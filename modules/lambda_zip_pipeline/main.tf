terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.src_org
}

module "common" {
  source       = "../pipeline_common"
  pipeline     = var.pipeline_name
  src_org      = var.src_org
  src_repo     = var.src_repo
  github_token = var.github_token
  vpc_config   = var.vpc_config
}
