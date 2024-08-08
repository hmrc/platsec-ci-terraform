data "aws_secretsmanager_secret_version" "sandbox_account_id" {
  secret_id = "platsec-sandbox-account-id"
}

data "aws_secretsmanager_secret_version" "s3_access_logs_bucket_name" {
  secret_id = "/terraform/platsec-ci-logging-bucket-name"
}

data "aws_secretsmanager_secret_version" "sandbox_role_arn" {
  for_each  = local.step_roles
  secret_id = "arn:aws:secretsmanager:eu-west-2:${data.aws_secretsmanager_secret_version.sandbox_account_id.secret_string}:secret:/shared/ci-${each.value}-role-arn"
}

data "aws_secretsmanager_secret_version" "development_account_id" {
  secret_id = "platsec-development-account-id"
}

data "aws_secretsmanager_secret_version" "development_role_arn" {
  for_each  = local.step_roles
  secret_id = "arn:aws:secretsmanager:eu-west-2:${data.aws_secretsmanager_secret_version.development_account_id.secret_string}:secret:/shared/ci-${each.value}-role-arn"
}

data "aws_secretsmanager_secret_version" "production_account_id" {
  secret_id = "platsec-production-account-id"
}

data "aws_secretsmanager_secret_version" "production_role_arn" {
  for_each  = local.step_roles
  secret_id = "arn:aws:secretsmanager:eu-west-2:${data.aws_secretsmanager_secret_version.production_account_id.secret_string}:secret:/shared/ci-${each.value}-role-arn"
}

data "aws_secretsmanager_secret_version" "central_audit_development_account_id" {
  secret_id = "central-audit-development-account-id"
}

data "aws_secretsmanager_secret_version" "central_audit_development_role_arn" {
  for_each  = toset(["terraform-applier", "terraform-planner"])
  secret_id = "arn:aws:secretsmanager:eu-west-2:${data.aws_secretsmanager_secret_version.central_audit_development_account_id.secret_string}:secret:/shared/ci-${each.value}-role-arn"
}

data "aws_secretsmanager_secret_version" "central_audit_production_account_id" {
  secret_id = "central-audit-production-account-id"
}

data "aws_secretsmanager_secret_version" "central_audit_production_role_arn" {
  for_each  = toset(["terraform-applier", "terraform-planner"])
  secret_id = "arn:aws:secretsmanager:eu-west-2:${data.aws_secretsmanager_secret_version.central_audit_production_account_id.secret_string}:secret:/shared/ci-${each.value}-role-arn"
}


data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = "/service_accounts/github_api_token"
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "ci" {
  backend = "s3"

  config = {
    bucket = local.state_bucket
    region = "eu-west-2"
    key    = "ci.tfstate"
  }
}