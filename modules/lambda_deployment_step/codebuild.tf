resource "aws_codebuild_project" "deploy" {
  name          = "${var.name_prefix}-lambda-deploy"
  build_timeout = 5

  service_role = aws_iam_role.deploy.arn

  vpc_config {
    security_group_ids = var.agent_security_group_ids
    subnets            = var.vpc_config.private_subnet_ids
    vpc_id             = var.vpc_config.vpc_id
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "DEPLOYMENT_ROLE_ARN"
      value = var.deployment_role_arn
    }
    environment_variable {
      name  = "LAMBDA_ARN"
      value = var.lambda_arn
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
