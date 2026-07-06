locals {
  step_assume_roles = merge(var.step_assume_roles...)

  # Pre-computed string ARN — using aws_iam_policy.ecr_push[0].arn here would leave the
  # element unknown at plan time and break toset() in the terraform_step module's for_each.
  ecr_push_policy_arns = length(var.ecr_push_repository_arns) == 0 ? [] : [
    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:policy/${var.pipeline_name}-ecr-push"
  ]
}


module "apply_step" {
  for_each = local.step_assume_roles
  source   = "../terraform_step"

  docker_required    = true
  step_name          = "${module.common.pipeline_name}-apply-${each.key}"
  timeout_in_minutes = var.test_timeout_in_minutes

  s3_bucket_arn = module.common.bucket_arn
  policy_arns = concat(
    [module.common.policy_build_core_arn, aws_iam_policy.secretsmanager.arn],
    local.ecr_push_policy_arns,
  )
  step_assume_roles   = each.value
  build_spec_contents = templatefile("${path.module}/buildspecs/apply.yaml.tpl", { target = each.key })

  vpc_config               = var.vpc_config
  agent_security_group_ids = values(var.agent_security_group_ids)

  tags = var.tags

  depends_on = [aws_iam_policy.ecr_push]
}
