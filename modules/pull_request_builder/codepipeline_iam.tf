data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      "${module.pr_builder_bucket.arn}/*/source_out/*"
    ]
  }

  statement {
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = [module.pr_builder_bucket.kms_key_arn]
  }

  statement {
    actions   = ["codestar-connections:UseConnection"]
    resources = [data.aws_codestarconnections_connection.this.arn]

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "codeconnections:FullRepositoryId"
      values   = [local.repository]
    }
  }

  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = [
      aws_codebuild_project.build.arn
    ]
  }
}

resource "aws_iam_policy" "codepipeline_policy" {
  name_prefix = substr(var.project_name, 0, 32)
  description = "${var.project_name} pipeline"
  policy      = data.aws_iam_policy_document.codepipeline_policy.json

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    codebuild_project = var.project_name
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name_prefix        = substr(var.project_name, 0, 32)
  description        = "${var.project_name} pipeline"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.codepipeline_policy.arn
  ]

  tags = {
    Step = var.project_name
  }
}