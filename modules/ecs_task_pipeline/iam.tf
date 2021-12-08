
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
      "${module.pipeline_bucket.bucket_arn}/*/source_out/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]

    resources = [
      "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/${local.pipeline}*"
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
      module.pipeline_bucket.kms_key_arn
    ]
  }
}

resource "aws_iam_policy" "codepipeline_policy" {
  name_prefix = substr(local.pipeline, 0, 32)
  description = "${local.pipeline} CodePipeline"
  policy      = data.aws_iam_policy_document.codepipeline_policy.json

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Pipeline = local.pipeline
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name_prefix         = substr(local.pipeline, 0, 32)
  description         = "${local.pipeline} CodePipeline"
  assume_role_policy  = data.aws_iam_policy_document.codepipeline_assume_role.json
  managed_policy_arns = [aws_iam_policy.codepipeline_policy.arn]

  tags = {
    Pipeline = local.pipeline
  }
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

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "build_core" {

  statement {
    sid = "VpcNetworking"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:CreateNetworkInterfacePermission"
    ]
    resources = [
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"
      values   = var.vpc_config.private_subnet_arns
    }
    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
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
      module.pipeline_bucket.kms_key_arn
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
    ]
    resources = [
      "${module.pipeline_bucket.bucket_arn}/*/source_out/*",
      "${module.pipeline_bucket.bucket_arn}/*/build_outp/*",
    ]
  }
}

data "aws_iam_policy_document" "store_artifacts" {
  statement {
    actions = [
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]
    resources = [
      "${module.pipeline_bucket.bucket_arn}/*/build_outp/*"
    ]
  }
}

resource "aws_iam_policy" "build_core" {
  name_prefix = substr(local.pipeline, 0, 32)
  description = "${local.pipeline} build"
  policy      = data.aws_iam_policy_document.build_core.json

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Pipeline = local.pipeline
  }
}

locals {
  artifactory_secret_manager_names = {
    token : "/artifactory/live/ci-token"
    username : "/artifactory/live/ci-username"
  }
}

data "aws_iam_policy_document" "get_artifactory_credentials" {
  statement {
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${local.artifactory_secret_manager_names.token}*",
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${local.artifactory_secret_manager_names.username}*",
    ]
  }
}

resource "aws_iam_policy" "get_artifactory_credentials" {
  name_prefix = substr(local.pipeline, 0, 32)
  description = "${local.pipeline} get artifactory credentials"
  policy      = data.aws_iam_policy_document.get_artifactory_credentials.json

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Pipeline = local.pipeline
  }
}

resource "aws_iam_policy" "store_artifacts" {
  name_prefix = substr(local.pipeline, 0, 32)
  description = "${local.pipeline} store artefacts"
  policy      = data.aws_iam_policy_document.store_artifacts.json

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Pipeline = local.pipeline
  }
}
