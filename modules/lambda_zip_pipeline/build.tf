module "build_artifact_step" {
  source                = "../build_artifact_step"
  docker_required       = false
  build_core_policy_arn = aws_iam_policy.build_core.arn
  name_prefix           = local.full_name
  s3_bucket_arn         = aws_s3_bucket.codepipeline_bucket.arn
}

module "lambda-deployment-step-development" {
  source = "../lambda_deployment_step"

  lambda_arn            = "arn:aws:lambda:${var.target_region}:${var.sandbox_deploy.account_id}:function:${var.lambda_function_name}"
  name_prefix           = "${local.full_name}-development"
  build_core_policy_arn = aws_iam_policy.build_core.arn
  deployment_role_arn   = var.sandbox_deploy.deployment_role_arn
}
