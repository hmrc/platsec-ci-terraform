data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = "/service_accounts/github_api_token"
}

module "common" {
  source               = "../pipeline_common"
  pipeline             = var.pipeline_name
  sns_topic_arn        = var.sns_topic_arn
  src_org              = var.src_org
  src_repo             = var.src_repo
  github_token         = data.aws_secretsmanager_secret_version.github_token.secret_string
  vpc_config           = var.vpc_config
  access_log_bucket_id = var.access_log_bucket_id
  admin_role           = var.admin_role
  //  pipeline_bucket_admin_roles = [
  //    local.tf_admin_role,
  //    local.tf_plan_role,
  //  ]
}
