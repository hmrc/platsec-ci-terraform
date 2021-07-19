resource "aws_codebuild_project" "deploy" {
  name          = "${var.name_prefix}-lambda-deploy"
  build_timeout = 5

  service_role = aws_iam_role.deploy.arn

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:latest"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

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
    type = "CODEPIPELINE"
    buildspec = templatefile("${path.module}/templates/buildspec-deploy.yaml.tpl", {
      function_arn : var.lambda_arn
    })
  }
}
