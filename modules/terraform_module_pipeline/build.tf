module "build_artifact_step" {
  source = "../build_artifact_step"

  docker_required    = true
  step_name          = "${module.common.pipeline_name}-build"
  timeout_in_minutes = 15

  s3_bucket_arn                    = module.common.bucket_arn
  vpc_config                       = var.vpc_config
  agent_security_group_ids         = [var.ci_agent_to_endpoints_sg_id, var.ci_agent_to_internet_sg_id]
  policy_arns                      = [module.common.policy_build_core_arn, module.common.policy_get_artifactory_credentials_arn]
  artifactory_secret_manager_names = module.common.artifactory_secret_manager_names
  step_assume_roles                = { STEP_ASSUME_ROLE_ARN : var.accounts.sandbox.role_arns["terraform-provisioner"] }
}

module "git_version_step" {
  source = "../git_version_step"

  step_name      = "${module.common.pipeline_name}-git-version"
  repository_url = "https://github.com/${var.src_org}/${var.src_repo}"
  branch         = var.branch

  vpc_config               = var.vpc_config
  agent_security_group_ids = [var.ci_agent_to_endpoints_sg_id, var.ci_agent_to_internet_sg_id]
  policy_arns              = [module.common.policy_build_core_arn, module.common.policy_get_artifactory_credentials_arn]
}
