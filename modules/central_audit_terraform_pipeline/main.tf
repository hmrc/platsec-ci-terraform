module "common" {
  source               = "../pipeline_common"
  pipeline             = var.pipeline_name
  sns_topic_arn        = var.sns_topic_arn
  src_org              = var.src_org
  src_repo             = var.src_repo
  codeconnection_arn   = var.codeconnection_arn
  vpc_config           = var.vpc_config
  access_log_bucket_id = var.access_log_bucket_id
  admin_roles          = var.admin_roles
  tags                 = var.tags
}
