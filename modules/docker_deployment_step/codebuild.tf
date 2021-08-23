resource "aws_codebuild_project" "deploy" {
  name          = "${var.name_prefix}-docker-deploy"
  build_timeout = 5

  service_role = aws_iam_role.deploy.arn

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "ECR_URL"
      value = var.ecr_url
    }
    environment_variable {
      name  = "LAMBDA_ARN"
      value = var.lambda_arn
    }
    environment_variable {
      name  = "DEPLOYMENT_ROLE_ARN"
      value = var.deployment_role_arn
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.name_prefix
      stream_name = var.name_prefix
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/assets/buildspec-deploy.yaml")
  }
}
