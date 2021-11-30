resource "aws_codepipeline" "codepipeline" {
  name     = local.pipeline
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.s3kmskey.arn
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
        OAuthToken           = var.github_token
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = module.build_artifact_step.name
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
    name = "Development"

    action {
      name            = "Deploy_Development"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ProjectName = module.zip-deployment-step-development.name
      }
    }

    action {
      name            = "Upload_to_Artifactory"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ProjectName = module.zip_upload_artifactory_step.name
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


  dynamic "stage" {
    for_each = local.is_live ? toset(["Approve_Production"]) : toset([])
    content {
      name = stage.value

      action {
        name     = stage.value
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
  }

  dynamic "stage" {
    for_each = local.is_live ? toset(["Deploy_Production"]) : toset([])

    content {
      name = stage.value

      action {
        name            = stage.value
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        input_artifacts = ["build_output"]
        version         = "1"

        configuration = {
          ProjectName = module.zip-deployment-step-production.name
        }
      }
    }
  }
}
