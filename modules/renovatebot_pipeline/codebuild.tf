resource "aws_codebuild_project" "this" {
  name          = "renovate"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = var.build_timeout_in_minutes

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    privileged_mode = false
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = local.name
      stream_name = local.name
    }
  }

  source {
    type                = "NO_SOURCE"
    report_build_status = false
    buildspec = templatefile(
      "${path.module}/buildspecs/buildspec.yaml.tftpl",
      {
        primary_repository = local.primary_repository
        repositories       = local.repositories
      }
    )
  }

  vpc_config {
    vpc_id             = var.vpc_config.vpc_id
    subnets            = var.vpc_config.private_subnet_ids
    security_group_ids = values(var.agent_security_group_ids)
  }

  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "this" {
  name                = "run_${local.name}_pipeline_at_interval"
  description         = "Runs ${local.name} CodeBuild Job At Defined Interval"
  schedule_expression = "cron(0 5 * * SUN *)"
}

resource "aws_cloudwatch_event_target" "this" {
  arn       = aws_codebuild_project.this.arn
  rule      = aws_cloudwatch_event_rule.this.name
  target_id = "run_${local.name}_pipeline"
  role_arn  = aws_iam_role.schedule_role.arn
}