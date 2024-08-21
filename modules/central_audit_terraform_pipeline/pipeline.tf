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

  dynamic "stage" {
    for_each = length(var.codeconnection_arn) > 0 ? [0] : []

    content {
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
  }

  dynamic "stage" {
    for_each = length(var.codeconnection_arn) == 0 ? [0] : []

    content {
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
  }

  stage {
    name = "apply-central-audit-terraform-development"

    action {
      name            = "apply-central-audit-terraform-development"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = module.apply_step["development"].name
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
    name = "apply-central-audit-terraform-production"

    action {
      name            = "apply-central-audit-terraform-production"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = module.apply_step["production"].name
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

  lifecycle {
    ignore_changes = [stage[0].action[0].configuration["OAuthToken"]]
  }
}
