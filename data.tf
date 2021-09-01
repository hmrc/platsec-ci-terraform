data "aws_secretsmanager_secret_version" "sandbox_account_id" {
  secret_id = "platsec-sandbox-account-id"
}

data "aws_secretsmanager_secret_version" "sandbox_deployment_role_arn" {
  secret_id = "arn:aws:secretsmanager:eu-west-2:${data.aws_secretsmanager_secret_version.sandbox_account_id.secret_string}:secret:/shared/ci-lambda-deploy-role-arn"
}

data "aws_secretsmanager_secret_version" "development_account_id" {
  secret_id = "platsec-development-account-id"
}

data "aws_secretsmanager_secret_version" "development_deployment_role_arn" {
  secret_id = "arn:aws:secretsmanager:eu-west-2:${data.aws_secretsmanager_secret_version.development_account_id.secret_string}:secret:/shared/ci-lambda-deploy-role-arn"
}

data "aws_secretsmanager_secret_version" "production_account_id" {
  secret_id = "platsec-production-account-id"
}

data "aws_secretsmanager_secret_version" "production_deployment_role_arn" {
  secret_id = "arn:aws:secretsmanager:eu-west-2:${data.aws_secretsmanager_secret_version.production_account_id.secret_string}:secret:/shared/ci-lambda-deploy-role-arn"
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = "/service_accounts/github_api_token"
}
