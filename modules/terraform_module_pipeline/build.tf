locals {
  agent_security_group_ids = values(var.agent_security_group_ids)
}
module "build_artifact_step" {
  source = "../build_artifact_step"

  docker_required    = true
  step_name          = "${module.common.pipeline_name}-build"
  timeout_in_minutes = var.test_timeout_in_minutes

  s3_bucket_arn                    = module.common.bucket_arn
  vpc_config                       = var.vpc_config
  agent_security_group_ids         = local.agent_security_group_ids
  policy_arns                      = [module.common.policy_build_core_arn, module.common.policy_get_artifactory_credentials_arn]
  artifactory_secret_manager_names = module.common.artifactory_secret_manager_names
  step_assume_roles                = { STEP_ASSUME_ROLE_ARN : var.accounts.sandbox.role_arns["terraform-applier"] }

  tags = var.tags
}

module "git_version_step" {
  source = "../git_version_step"

  step_name       = "${module.common.pipeline_name}-git-version"
  repository_url  = "https://github.com/${var.src_org}/${var.src_repo}"
  branch          = var.branch
  repository_name = var.src_repo

  vpc_config               = var.vpc_config
  agent_security_group_ids = local.agent_security_group_ids
  policy_arns              = [module.common.policy_build_core_arn, module.common.policy_get_artifactory_credentials_arn]

  tags = var.tags
}

module "git_tag_step" {
  source = "../git_tag_step"

  step_name       = "${module.common.pipeline_name}-git-tag"
  repository_name = var.src_repo

  vpc_config               = var.vpc_config
  agent_security_group_ids = local.agent_security_group_ids
  policy_arns              = [module.common.policy_build_core_arn, module.common.policy_get_artifactory_credentials_arn]

  tags = var.tags
}
