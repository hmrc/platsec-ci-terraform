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
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      namespace        = "SourceVariables"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.codeconnection_arn
        FullRepositoryId = "${var.src_org}/${var.src_repo}"
        BranchName       = var.branch
      }
    }
  }

  stage {
    name = "pre-apply"

    action {
      name            = "create-timestamp"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"
      namespace       = "Timestamp"

      configuration = {
        ProjectName = module.build_timestamp_step.name
      }
    }
  }

  stage {
    name = "apply-ci"

    action {
      name            = "apply-ci"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = module.apply_step["ci"].name
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

  stage {
    name = "approve-live"

    action {
      name     = "approve-live"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        ExternalEntityLink : "https://github.com/${var.src_org}/${var.src_repo}/commit/#{SourceVariables.CommitId}"
        CustomData : "#{SourceVariables.CommitMessage}"
      }
    }
  }

  stage {
    name = "apply-live"

    action {
      name            = "apply-live"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = module.apply_step["live"].name
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

  tags = var.tags
}
