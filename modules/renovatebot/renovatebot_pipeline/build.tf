resource "aws_codebuild_project" "renovate_project" {
  name         = "renovate_pipeline"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = ""
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "GITHUB_TOKEN"
      value = var.github_token
      type  = "PLAINTEXT"
    }
  }

  source {
    type      = "GITHUB"
    location  = []
    buildspec = "renovate.json" 
  }
}
