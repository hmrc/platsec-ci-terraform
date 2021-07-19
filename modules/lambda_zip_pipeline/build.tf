module "build_artifact_step" {
  source                = "../build_artifact_step"
  docker_required       = false
  build_core_policy_arn = aws_iam_policy.build_core.arn
  name_prefix           = local.full_name
  s3_bucket_arn         = aws_s3_bucket.codepipeline_bucket.arn
}

module "lambda-deployment-step-development" {
  source = "../lambda_deployment_step"

  lambda_arn            = var.deploy_production_lambda_arn
  name_prefix           = "${local.full_name}-development"
  build_core_policy_arn = aws_iam_policy.build_core.arn
  deployment_role_arn   = var.deployment_role_arn_development
}

module "lambda-deployment-step-production" {
  source = "../lambda_deployment_step"

  lambda_arn            = var.deploy_development_lambda_arn
  name_prefix           = "${local.full_name}-production"
  build_core_policy_arn = aws_iam_policy.build_core.arn
  deployment_role_arn   = var.deployment_role_arn_production #todo change to production arn
}

