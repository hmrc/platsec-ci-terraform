resource "aws_codebuild_project" "deploy" {
  name          = var.step_name
  build_timeout = var.upload_image_timeout_in_minutes

  service_role = aws_iam_role.deploy.arn

  vpc_config {
    security_group_ids = var.agent_security_group_ids
    subnets            = var.vpc_config.private_subnet_ids
    vpc_id             = var.vpc_config.vpc_id
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "ECR_URL"
      value = var.ecr_url
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.step_name
      stream_name = var.step_name
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/assets/upload-to-ecr.yaml")
  }

  tags = var.tags
}
