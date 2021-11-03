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

locals {
  full_name = "${var.name_prefix}-${var.pipeline_name}"
}
