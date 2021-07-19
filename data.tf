data "aws_secretsmanager_secret_version" "sandbox_account_id" {
  secret_id = "platsec-sandbox-account-id"
}

data "aws_secretsmanager_secret_version" "deployment_role_arn_sandbox" {
  secret_id = "arn:aws:secretsmanager:eu-west-2:${data.aws_secretsmanager_secret_version.sandbox_account_id.secret_string}:secret:/shared/ci_deployment_arn"
}
// #todo create roles in dev and prod
//data "aws_secretsmanager_secret_version" "development_account_id" {
//  secret_id = "platsec-development-account-id"
//}
//
//data "aws_secretsmanager_secret_version" "deployment_role_arn_development" {
//  secret_id = "arn:aws:secretsmanager:eu-west-2:${data.aws_secretsmanager_secret_version.development_account_id.secret_string}:secret:/shared/ci_deployment_arn"
//}
//
//data "aws_secretsmanager_secret_version" "production_account_id" {
//  secret_id = "platsec-production-account-id"
//}
//
//data "aws_secretsmanager_secret_version" "deployment_role_arn_production" {
//  secret_id = "arn:aws:secretsmanager:eu-west-2:${data.aws_secretsmanager_secret_version.production_account_id.secret_string}:secret:/shared/ci_deployment_arn"
//}
