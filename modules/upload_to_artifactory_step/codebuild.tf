resource "aws_codebuild_project" "upload" {
  name          = var.step_name
  build_timeout = 5

  service_role = aws_iam_role.upload.arn

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
    privileged_mode             = true

    environment_variable {
      name  = "REPO_URL"
      value = "artefacts.tax.service.gov.uk/${var.docker_repo_name}"
    }
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
      group_name  = var.step_name
      stream_name = var.step_name
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/assets/upload-to-artifactory.yaml")
  }
}
