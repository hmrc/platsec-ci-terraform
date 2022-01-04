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
  step_roles = toset(["lambda-deploy", "ecr-upload", "ecs-task-update"])

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
/*
module "prowler_worker" {
  source = "./modules/lambda_docker_pipeline"

  pipeline_name = "prowler-worker"
  src_repo      = "platsec-prowler-lambda-worker"
  branch        = "main"
  github_token  = data.aws_secretsmanager_secret_version.github_token.secret_string

  lambda_function_name = "platsec_lambda_prowler_scanner"
  ecr_name             = "platsec-prowler"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
}
https://signin.aws.amazon.com/switchrole?account=987972305662&roleName=RoleSecurityEngineer&displayName=platsec-ci/SecurityEngineer
module "aws_scanner" {
  source = "./modules/lambda_docker_pipeline"

  pipeline_name = "aws-scanner"
  src_repo      = "platsec-aws-scanner"
  branch        = "main"


  lambda_function_name = "platsec_aws_scanner_lambda"
  ecr_name             = "platsec-aws-scanner"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
}

module "compliance_alerting" {
  source = "./modules/lambda_docker_pipeline"

  pipeline_name = "compliance-alerting"
  src_repo      = "platsec-compliance-alerting"
  branch        = "main"


  lambda_function_name = "platsec_compliance_alerting_lambda"
  ecr_name             = "platsec-compliance-alerting"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
}

module "cloudtrail_monitoring" {
  source = "./modules/lambda_zip_pipeline"

  pipeline_name = "cloudtrail-monitoring"
  src_repo      = "platsec-cloudtrail-monitoring"
  branch        = "main"
  github_token  = data.aws_secretsmanager_secret_version.github_token.secret_string

  lambda_function_name = "platsec_cloudtrail_monitoring"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
}

module "github_webhook_report" {
  source = "./modules/lambda_docker_pipeline"

  pipeline_name = "github-webhook-report"
  src_repo      = "github-webhook-report-lambda"
  branch        = "main"


  lambda_function_name = "github_webhook_report_lambda"
  ecr_name             = "github-webhook-report"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
}

module "compliance_dataviz" {
  source = "./modules/ecs_task_pipeline"

  pipeline_name = "compliance-dataviz"
  src_repo      = "platsec-compliance-dataviz"
  branch        = "main"

  ecr_name     = "platsec-compliance-dataviz"
  cluster_name = "security_reports_frontend"
  service_name = "compliance_dataviz"
  task_name    = "compliance_dataviz_task"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
}

module "sandbox_aws_nuke" {
  source = "./modules/sandbox_lambda_docker_pipeline"

  pipeline_name = "sandbox-aws-nuke"
  src_repo      = "platsec-aws-nuke-lambda"
  branch        = "main"

  lambda_function_name = "go-nuke"
  ecr_name             = "go-nuke"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
}
*/
module "sandbox_compliance_alerting" {
  source = "./modules/sandbox_lambda_docker_pipeline"

  pipeline_name = "sandbox-compliance-alerting"
  src_repo      = "platsec-compliance-alerting"
  branch        = "sandbox"


  lambda_function_name = "platsec_compliance_alerting_lambda"
  ecr_name             = "platsec-compliance-alerting"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
}
