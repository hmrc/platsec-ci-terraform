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
  lambda_arn            = var.deploy_production_lambda_arn
  ecr_arn               = var.ecr_arn
  ecr_url               = var.ecr_url
}
