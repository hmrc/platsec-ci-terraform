locals {
  step_assume_roles = merge(var.step_assume_roles...)
}


module "apply_step" {
  for_each = local.step_assume_roles
  source   = "../terraform_step"

  docker_required    = true
  step_name          = "${module.common.pipeline_name}-apply-${each.key}"
  timeout_in_minutes = var.test_timeout_in_minutes

  s3_bucket_arn       = module.common.bucket_arn
  policy_arns         = [module.common.policy_build_core_arn]
  step_assume_roles   = each.value
  build_spec_contents = templatefile("${path.module}/buildspecs/apply.yaml.tpl", { target = each.key })

  vpc_config               = var.vpc_config
  agent_security_group_ids = [var.ci_agent_to_endpoints_sg_id, var.ci_agent_to_internet_sg_id]
}
