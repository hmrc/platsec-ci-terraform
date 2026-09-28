terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

locals {
  pipeline_name = var.pipeline
  build_id      = "#{SourceVariables.CommitId}-#{Timestamp.BUILD_TIMESTAMP}"
}
