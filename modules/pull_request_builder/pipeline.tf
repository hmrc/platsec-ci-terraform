resource "aws_codepipeline" "pipeline" {
  name           = var.project_name
  role_arn       = aws_iam_role.codepipeline_role.arn
  pipeline_type  = "V2"
  execution_mode = "QUEUED"

  artifact_store {
    location = module.pr_builder_bucket.id
    type     = "S3"

    encryption_key {
      id   = module.pr_builder_bucket.kms_key_arn
      type = "KMS"
    }
  }

  trigger {
    provider_type = "CodeStarSourceConnection"

    git_configuration {
      #must equal source stage.action.name
      source_action_name = "Source"

      pull_request {
        events = ["OPEN", "UPDATED"]
      }
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = data.aws_codestarconnections_connection.this.arn
        FullRepositoryId = local.repository
        BranchName       = "main*"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }
}