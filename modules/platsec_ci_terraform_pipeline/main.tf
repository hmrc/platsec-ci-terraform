module "common" {
  source               = "../pipeline_common"
  pipeline             = var.pipeline_name
  src_org              = var.src_org
  src_repo             = var.src_repo
  github_token         = data.aws_secretsmanager_secret_version.github_token.secret_string
  vpc_config           = var.vpc_config
  sns_topic_arn        = var.sns_topic_arn
  access_log_bucket_id = var.access_log_bucket_id
  admin_roles          = var.admin_roles
}