data "aws_caller_identity" "current" {}

#TODO: add TF resource config for account ids below in platsec-terraform and central-audit-terraform repos
data "aws_secretsmanager_secret_version" "sandbox_account_id" {
  secret_id = "platsec-sandbox-account-id"
}

data "aws_secretsmanager_secret_version" "development_account_id" {
  secret_id = "platsec-development-account-id"
}

data "aws_secretsmanager_secret_version" "production_account_id" {
  secret_id = "platsec-production-account-id"
}

data "aws_secretsmanager_secret_version" "central_audit_development_account_id" {
  secret_id = "central-audit-development-account-id"
}

data "aws_secretsmanager_secret_version" "central_audit_production_account_id" {
  secret_id = "central-audit-production-account-id"
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = "/service_accounts/github_api_token"
}

data "aws_secretsmanager_secret_version" "s3_access_logs_bucket_name" {
  secret_id = "/terraform/platsec-ci-logging-bucket-name"
}
