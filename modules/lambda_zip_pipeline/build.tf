module "build_artifact_step" {
  source                = "../build_artifact_step"
  docker_required       = var.docker_build_required
  build_core_policy_arn = aws_iam_policy.build_core.arn
  name_prefix           = local.full_name
  s3_bucket_arn         = aws_s3_bucket.codepipeline_bucket.arn
  vpc_config            = var.vpc_config
}

module "lambda-deployment-step-development" {
  source = "../lambda_deployment_step"

  lambda_arn            = "arn:aws:lambda:${var.target_region}:${var.accounts.development.id}:function:${var.lambda_function_name}"
  name_prefix           = "${local.full_name}-development"
  build_core_policy_arn = aws_iam_policy.build_core.arn
  deployment_role_arn   = var.accounts.development.deployment_role_arn
}

module "lambda-deployment-step-production" {
  source = "../lambda_deployment_step"

  lambda_arn            = "arn:aws:lambda:${var.target_region}:${var.accounts.production.id}:function:${var.lambda_function_name}"
  name_prefix           = "${local.full_name}-production"
  build_core_policy_arn = aws_iam_policy.build_core.arn
  deployment_role_arn   = var.accounts.production.deployment_role_arn
}
