terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
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
  is_live                = terraform.workspace == "live"
  prefix                 = local.is_live ? "platsec-ci-" : "platsec-${terraform.workspace}-"
  step_roles             = toset(["lambda-deploy", "ecr-upload", "ecs-task-update", "terraform-applier", "terraform-planner"])
  terraform_applier_role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformApplier"
  terraform_planner_role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformPlanner"
  access_log_bucket_id   = nonsensitive(data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string)

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

    central_audit_production : {
      id : nonsensitive(tonumber(data.aws_secretsmanager_secret_version.central_audit_production_account_id.secret_string))
      role_arns : { for role, secret in data.aws_secretsmanager_secret_version.central_audit_production_role_arn : role => nonsensitive(secret.secret_string) }
    }

    central_audit_development : {
      id : nonsensitive(tonumber(data.aws_secretsmanager_secret_version.central_audit_development_account_id.secret_string))
      role_arns : { for role, secret in data.aws_secretsmanager_secret_version.central_audit_development_role_arn : role => nonsensitive(secret.secret_string) }
    }
  }
  all_platsec_account_ids = [for account in values(local.accounts) : account.id]

  tf_admin_role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformProvisioner"
}

module "label" {
  source = "github.com/hmrc/terraform-null-label?ref=0.25.0"

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

