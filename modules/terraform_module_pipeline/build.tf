locals {
  agent_security_group_ids = values(var.agent_security_group_ids)
}
module "git_version_step" {
  source = "../git_version_step"

  step_name       = "${module.common.pipeline_name}-git-version"
  repository_url  = "https://github.com/${var.src_org}/${var.src_repo}"
  branch          = var.branch
  repository_name = var.src_repo

  vpc_config               = var.vpc_config
  agent_security_group_ids = local.agent_security_group_ids
  policy_arns              = [module.common.policy_build_core_arn]

  tags = var.tags
}

module "git_tag_step" {
  source = "../git_tag_step"

  step_name       = "${module.common.pipeline_name}-git-tag"
  repository_name = var.src_repo

  vpc_config               = var.vpc_config
  agent_security_group_ids = local.agent_security_group_ids
  policy_arns              = [module.common.policy_build_core_arn]

  tags = var.tags
}
