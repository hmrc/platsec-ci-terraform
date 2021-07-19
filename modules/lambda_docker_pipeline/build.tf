module "build_artifact_step" {
  source                = "../build_artifact_step"
  docker_required       = true
  build_core_policy_arn = aws_iam_policy.build_core.arn
  name_prefix           = local.full_name
  s3_bucket_arn         = aws_s3_bucket.codepipeline_bucket.arn
}

module "docker_deployment_development" {
  source = "../docker_deployment_step"

  name_prefix           = "${local.full_name}-development"
  build_core_policy_arn = aws_iam_policy.build_core.arn
  lambda_arn            = "arn:aws:lambda:${var.target_region}.:${var.development_deploy.account_id}:function:${var.lambda_function_name}"
  ecr_arn               = aws_ecr_repository.lambda.arn
  ecr_url               = aws_ecr_repository.lambda.repository_url
  deployment_role_arn   = var.development_deploy.deployment_role_arn
}
