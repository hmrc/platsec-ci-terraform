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
  is_live    = terraform.workspace == "live"
  prefix     = local.is_live ? "platsec-ci-" : "platsec-${terraform.workspace}-"
  step_roles = toset(["lambda-deploy", "ecr-upload", "ecs-task-update", "terraform-provisioner"])

  accounts = {
    sandbox : {
      id : nonsensitive(tonumber(data.aws_secretsmanager_secret_version.sandbox_account_id.secret_string))
      role_arns : { for role, secret in data.aws_secretsmanager_secret_version.sandbox_role_arn : role => nonsensitive(secret.secret_string) }
    }
    development : {
      id : nonsensitive(tonumber(data.aws_secretsmanager_secret_version.development_account_id.secret_string))
      role_arns : { for role, secret in data.aws_secretsmanager_secret_version.development_role_arn : role => nonsensitive(secret.secret_string) }
    }

    production : {
      id : nonsensitive(tonumber(data.aws_secretsmanager_secret_version.production_account_id.secret_string))
      role_arns : { for role, secret in data.aws_secretsmanager_secret_version.production_role_arn : role => nonsensitive(secret.secret_string) }
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

module "ci_alerts_for_sandbox" {
  source = "./modules/alerting_sns_topics"

  topic_name              = "ci_alerts_for_sandbox"
  subscription_account_no = local.accounts.sandbox.id
}

module "ci_alerts_for_development" {
  source = "./modules/alerting_sns_topics"

  topic_name              = "ci_alerts_for_development"
  subscription_account_no = local.accounts.development.id
}

module "ci_alerts_for_production" {
  source = "./modules/alerting_sns_topics"

  topic_name              = "ci_alerts_for_production"
  subscription_account_no = local.accounts.production.id
}

module "access_logs" {
  source      = "./modules/access_logs_bucket"
  account_id  = data.aws_caller_identity.current.id
  bucket_name = "${local.prefix}access-logs"
}
