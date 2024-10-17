resource "aws_codebuild_project" "renovate_project" {
  name          = "${module.common.pipeline_name}-renovate"
  service_role  = module.common.policy_build_core_arn
  build_timeout = var.build_timeout_in_minutes

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:6.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  cache {
    type     = "S3"
    location = module.common.bucket_arn
  }

  vpc_config {
    vpc_id             = var.vpc_config.vpc_id
    subnets            = var.vpc_config.private_subnet_ids
    security_group_ids = values(var.agent_security_group_ids)
  }

  tags = var.tags
}

resource "aws_codepipeline" "renovate_pipeline" {
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
    name = "Build"

    action {
      name            = "Renovate"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.renovate_project.name
      }
    }
  }

  tags = var.tags
}
