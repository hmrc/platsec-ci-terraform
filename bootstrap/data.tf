data "aws_region" "current" {}

data "aws_secretsmanager_secret_version" "production_account_id" {
  secret_id = "platsec-production-account-id"
}
