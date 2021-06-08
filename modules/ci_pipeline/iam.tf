
data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    principals {
      identifiers = ["codepipeline.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "codepipeline_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:GetObjectVersion",
      "s3:GetObject",
      "s3:GetBucketVersioning"
    ]
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = [
      var.github_connection_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]

    resources = [
      aws_codebuild_project.build.arn,
      module.lambda-deployment-step-development.arn,
      module.lambda-deployment-step-production.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:Decrypt",
    ]
    resources = [
      var.kms_key_arn
    ]
  }
}

resource "aws_iam_policy" "codepipeline_policy" {
  name_prefix = "${local.full_name}-codepipeline"
  policy      = data.aws_iam_policy_document.codepipeline_policy.json

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name                = "${local.full_name}-codepipeline"
  assume_role_policy  = data.aws_iam_policy_document.codepipeline_assume_role.json
  managed_policy_arns = [aws_iam_policy.codepipeline_policy.arn]
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    principals {
      identifiers = ["codebuild.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "build_core" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      var.kms_key_arn
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
    ]
    resources = [
      "${var.s3_bucket_arn}/${var.pipeline_name}*"
    ]
  }
}

data "aws_iam_policy_document" "store_artifacts" {
  statement {
    actions = [
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]
    resources = [
      "${var.s3_bucket_arn}/${var.pipeline_name}*"
    ]
  }
}

resource "aws_iam_policy" "build_core" {
  name_prefix = "${local.full_name}-build-core"
  policy      = data.aws_iam_policy_document.build_core.json

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_iam_policy" "store_artifacts" {
  name_prefix = "${local.full_name}-build-store-artifacts"
  policy      = data.aws_iam_policy_document.store_artifacts.json

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "build" {
  name               = "${local.full_name}-build"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.build_core.arn,
    aws_iam_policy.store_artifacts.arn
  ]
}