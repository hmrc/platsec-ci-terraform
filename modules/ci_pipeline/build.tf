resource "aws_codebuild_project" "build" {
  name          = "${local.full_name}-build-image"
  description   = "For ${var.pipeline_name}"
  build_timeout = 10

  service_role = aws_iam_role.build.arn

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = local.full_name
      stream_name = local.full_name
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }
  source {
    type = "CODEPIPELINE"
  }
}

module "lambda-deployment-step-development" {
  source = "../lambda_deployment_step"

  lambda_arn            = var.deploy_production_lambda_arn
  name_prefix           = "${local.full_name}-development"
  build_core_policy_arn = aws_iam_policy.build_core.arn
}

module "lambda-deployment-step-production" {
  source = "../lambda_deployment_step"

  lambda_arn            = var.deploy_development_lambda_arn
  name_prefix           = "${local.full_name}-production"
  build_core_policy_arn = aws_iam_policy.build_core.arn
}

