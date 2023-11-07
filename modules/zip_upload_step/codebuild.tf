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
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ARTEFACT_URL"
      value = "https://artefacts.tax.service.gov.uk/artifactory/platsec-lambda-packages"
    }
    environment_variable {
      type  = "SECRETS_MANAGER"
      name  = "ARTIFACTORY_TOKEN"
      value = var.artifactory_secret_manager_names.token
    }
    environment_variable {
      name  = "PACKAGE_NAME"
      value = var.package_name
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
    buildspec = file("${path.module}/assets/upload_artifactory.yaml")
  }
}
