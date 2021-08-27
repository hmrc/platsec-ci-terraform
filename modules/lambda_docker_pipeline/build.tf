module "build_artifact_step" {
  source = "../build_artifact_step"

  docker_required = true
  name_prefix     = local.full_name

  s3_bucket_arn                    = aws_s3_bucket.codepipeline_bucket.arn
  vpc_config                       = var.vpc_config
  agent_security_group_ids         = [var.ci_agent_to_endpoints_sg_id, var.ci_agent_to_internet_sg_id]
  policy_arns                      = [aws_iam_policy.build_core.arn, aws_iam_policy.get_artifactory_credentials.arn]
  artifactory_secret_manager_names = local.artifactory_secret_manager_names
}

module "docker_deployment_development" {
  source = "../docker_deployment_step"

  name_prefix           = "${local.full_name}-development"
  build_core_policy_arn = aws_iam_policy.build_core.arn
  lambda_arn            = "arn:aws:lambda:${var.target_region}:${var.accounts.development.id}:function:${var.lambda_function_name}"
  ecr_url               = "${var.accounts.development.id}.dkr.ecr.${var.target_region}.amazonaws.com/${var.ecr_name}"
  deployment_role_arn   = var.accounts.development.deployment_role_arn

  vpc_config               = var.vpc_config
  agent_security_group_ids = [var.ci_agent_to_endpoints_sg_id]
}

module "docker_deployment_production" {
  source = "../docker_deployment_step"

  name_prefix           = "${local.full_name}-production"
  build_core_policy_arn = aws_iam_policy.build_core.arn
  lambda_arn            = "arn:aws:lambda:${var.target_region}:${var.accounts.production.id}:function:${var.lambda_function_name}"
  ecr_url               = "${var.accounts.production.id}.dkr.ecr.${var.target_region}.amazonaws.com/${var.ecr_name}"
  deployment_role_arn   = var.accounts.production.deployment_role_arn

  vpc_config               = var.vpc_config
  agent_security_group_ids = [var.ci_agent_to_endpoints_sg_id]
}
