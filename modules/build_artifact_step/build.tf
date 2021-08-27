resource "aws_codebuild_project" "build" {
  name          = "${var.name_prefix}-build"
  description   = "For ${var.name_prefix}"
  build_timeout = 10

  service_role = aws_iam_role.build.arn

  vpc_config {
    security_group_ids = var.agent_security_group_ids
    subnets            = var.vpc_config.private_subnet_ids
    vpc_id             = var.vpc_config.vpc_id
  }

  cache {
    type  = "LOCAL"
    modes = var.docker_required ? ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"] : ["LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = var.docker_required

    environment_variable {
      type  = "SECRETS_MANAGER"
      name  = "ARTIFACTORY_TOKEN"
      value = var.artifactory_secret_manager_names.token
    }
    environment_variable {
      type  = "SECRETS_MANAGER"
      name  = "ARTIFACTORY_USERNAME"
      value = var.artifactory_secret_manager_names.username
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
  }
}
