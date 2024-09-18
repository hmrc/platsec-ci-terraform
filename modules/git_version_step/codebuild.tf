resource "aws_codebuild_project" "git_version" {
  name          = var.step_name
  build_timeout = 5

  service_role = aws_iam_role.codebuild.arn

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
      type  = "PLAINTEXT"
      name  = "REPOSITORY_URL"
      value = var.repository_url
    }
    environment_variable {
      type  = "PLAINTEXT"
      name  = "REPOSITORY_NAME"
      value = var.repository_name
    }
    environment_variable {
      type  = "PLAINTEXT"
      name  = "BRANCH"
      value = var.branch
    }
    environment_variable {
      type  = "PLAINTEXT"
      name  = "DOCKER_IMAGE_TAG"
      value = "5.8.1-alpine.3.14-6.0-amd64"
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
    buildspec = file("${path.module}/assets/git-version.yaml")
  }

  tags = var.tags
}
