resource "aws_codepipeline" "codepipeline" {
  name     = module.common.pipeline_name
  role_arn = module.common.codepipeline_role_arn

  artifact_store {
    location = module.common.bucket_id
    type     = "S3"

    encryption_key {
      id   = module.common.kms_key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      namespace        = "SourceVariables"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner                = var.src_org
        Repo                 = var.src_repo
        PollForSourceChanges = false
        Branch               = var.branch
        OAuthToken           = data.aws_secretsmanager_secret_version.github_token.secret_string
      }
    }
  }

  stage {
    name = "apply-central-development"

    action {
      name            = "apply-central-audit-development"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = module.apply_step["central_audit_development"].name
        EnvironmentVariables = jsonencode([
          {
            name  = "COMMIT_ID"
            value = "#{SourceVariables.CommitId}"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }
}