module "build_artifact_step" {
  source = "../build_artifact_step"

  docker_required = var.docker_build_required
  policy_arns     = [aws_iam_policy.build_core.arn, aws_iam_policy.get_artifactory_credentials.arn]
  step_name       = "${local.pipeline}-build"
  s3_bucket_arn   = aws_s3_bucket.codepipeline_bucket.arn

  vpc_config                       = var.vpc_config
  agent_security_group_ids         = [var.ci_agent_to_endpoints_sg_id, var.ci_agent_to_internet_sg_id]
  artifactory_secret_manager_names = local.artifactory_secret_manager_names
}

module "zip_upload_artifactory_step" {
  source       = "../zip_upload_step"
  step_name    = "${local.pipeline}-artifactory"
  package_name = var.src_repo
  policy_arns  = [aws_iam_policy.build_core.arn, aws_iam_policy.get_artifactory_credentials.arn]

  artifactory_secret_manager_names = local.artifactory_secret_manager_names
  vpc_config                       = var.vpc_config
  agent_security_group_ids         = [var.ci_agent_to_endpoints_sg_id]
}

module "zip-deployment-step-development" {
  source = "../zip_deployment_step"

  lambda_arn            = "arn:aws:lambda:${var.target_region}:${var.accounts.development.id}:function:${var.lambda_function_name}"
  step_name             = "${local.pipeline}-development"
  build_core_policy_arn = aws_iam_policy.build_core.arn
  deployment_role_arn   = var.accounts.development.deployment_role_arn

  vpc_config               = var.vpc_config
  agent_security_group_ids = [var.ci_agent_to_endpoints_sg_id]
}

module "zip-deployment-step-production" {
  source = "../zip_deployment_step"

  lambda_arn            = "arn:aws:lambda:${var.target_region}:${var.accounts.production.id}:function:${var.lambda_function_name}"
  step_name             = "${local.pipeline}-production"
  build_core_policy_arn = aws_iam_policy.build_core.arn
  deployment_role_arn   = var.accounts.production.deployment_role_arn

  vpc_config               = var.vpc_config
  agent_security_group_ids = [var.ci_agent_to_endpoints_sg_id]
}
