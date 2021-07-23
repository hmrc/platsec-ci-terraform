terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    key    = "platsec-ci/v1"
    bucket = "\n-------------------------\nPlease read the README.md first 📖\n------------------------"
    region = "\n-------------------------\nPlease read the README.md first 📖\n------------------------"
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = module.label.tags
  }
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  namespace = "mdtp"
  stage     = terraform.workspace
  name      = "platsec-ci"
}

module "ci_common" {
  source      = "./modules/ci_common"
  name_prefix = module.label.id
}

module "prowler_worker" {
  source                = "./modules/lambda_docker_pipeline"
  name_prefix           = module.label.id
  github_connection_arn = module.ci_common.github_connection_arn

  pipeline_name         = "prowler-worker"
  src_org               = "hmrc"
  src_repo              = "platsec-prowler-lambda-worker"
  branch                = "add_buildspec"
  docker_build_required = true

  lambda_function_name = "platsec_lambda_prowler_scanner"
  ecr_name             = "platsec-prowler"

  development_deploy = {
    account_id : tonumber(data.aws_secretsmanager_secret_version.development_account_id.secret_string)
    deployment_role_arn : data.aws_secretsmanager_secret_version.development_deployment_role_arn.secret_string
  }
}
