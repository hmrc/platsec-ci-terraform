resource "aws_codebuild_project" "deploy" {
  name          = "${var.name_prefix}-deploy"
  build_timeout = 5

  service_role = aws_iam_role.deploy.arn

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
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