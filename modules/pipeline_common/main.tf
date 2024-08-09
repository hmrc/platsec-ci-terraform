terraform {
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
      version = "~> 3.0"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.src_org
}

locals {
  is_live       = terraform.workspace == "live"
  pipeline_name = var.pipeline
  build_id      = "#{SourceVariables.CommitId}-#{Timestamp.BUILD_TIMESTAMP}"
  artifactory_secret_manager_names = {
    token : "/artifactory/live/ci-token"
    username : "/artifactory/live/ci-username"
  }
}
