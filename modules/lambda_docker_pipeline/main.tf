terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

locals {
  is_live = terraform.workspace == "live"
  prefix  = local.is_live ? "platsec-ci-" : "platsec-${terraform.workspace}-"
}

module "common" {
  source       = "../pipeline_common"
  pipeline     = var.pipeline_name
  src_org      = var.src_org
  src_repo     = var.src_repo
  github_token = var.github_token
  vpc_config   = var.vpc_config
  sns_topic_arn = var.sns_topic_arn
  access_log_bucket_id = "${local.prefix}access-logs"
}
