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

# https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/625
provider "aws" {
  alias  = "no-default-tags"
  region = "eu-west-2"
}

locals {
  accounts = {
    sandbox : {
      id : nonsensitive(tonumber(data.aws_secretsmanager_secret_version.sandbox_account_id.secret_string))
      deployment_role_arn : nonsensitive(data.aws_secretsmanager_secret_version.sandbox_deployment_role_arn.secret_string)
    }
    development : {
      id : nonsensitive(tonumber(data.aws_secretsmanager_secret_version.development_account_id.secret_string))
      deployment_role_arn : nonsensitive(data.aws_secretsmanager_secret_version.development_deployment_role_arn.secret_string)
    }

    production : {
      id : nonsensitive(tonumber(data.aws_secretsmanager_secret_version.production_account_id.secret_string))
      deployment_role_arn : nonsensitive(data.aws_secretsmanager_secret_version.production_deployment_role_arn.secret_string)
    }
  }
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  namespace = "mdtp"
  stage     = terraform.workspace
  name      = "platsec-ci"
}

module "networking" {
  providers = {
    aws.no-default-tags = aws.no-default-tags
  }

  name_prefix = module.label.id
  source      = "./modules/networking"
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = "/service_accounts/github_api_token"
}

module "prowler_worker" {
  source      = "./modules/lambda_docker_pipeline"
  name_prefix = module.label.id

  pipeline_name = "prowler-worker"
  src_repo      = "platsec-prowler-lambda-worker"
  branch        = "master"
  github_token  = data.aws_secretsmanager_secret_version.github_token.secret_string

  lambda_function_name = "platsec_lambda_prowler_scanner"
  ecr_name             = "platsec-prowler"

  accounts                    = local.accounts
  vpc_config                  = module.networking.vpc_config
  ci_agent_to_internet_sg_id  = module.networking.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = module.networking.ci_agent_to_endpoints_sg_id
}


module "cloudtrail_monitoring" {
  source      = "./modules/lambda_zip_pipeline"
  name_prefix = module.label.id

  pipeline_name = "cloudtrail-monitoring"
  src_repo      = "platsec-cloudtrail-monitoring"
  branch        = "master"
  github_token  = data.aws_secretsmanager_secret_version.github_token.secret_string

  lambda_function_name = "platsec_cloudtrail_monitoring"

  accounts                    = local.accounts
  vpc_config                  = module.networking.vpc_config
  ci_agent_to_internet_sg_id  = module.networking.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = module.networking.ci_agent_to_endpoints_sg_id
}
