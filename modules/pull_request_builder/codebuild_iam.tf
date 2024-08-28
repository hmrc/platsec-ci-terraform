locals {
  default_policy_arns = [aws_iam_policy.codebuild_policy.arn]
  managed_policy_arns = length(var.project_assume_roles) == 0 ? local.default_policy_arns : concat(local.default_policy_arns, [aws_iam_policy.codebuild_project_assume_roles_policy[0].arn])
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

data "aws_iam_policy_document" "codebuild_project_assume_roles_policy" {
  count = length(var.project_assume_roles) == 0 ? 0 : 1

  statement {
    actions = [
      "sts:AssumeRole"
    ]

    resources = values(var.project_assume_roles)
  }
}

resource "aws_iam_policy" "codebuild_project_assume_roles_policy" {
  count = length(var.project_assume_roles) == 0 ? 0 : 1

  name_prefix = substr(var.project_name, 0, 32)
  policy      = data.aws_iam_policy_document.codebuild_project_assume_roles_policy[0].json
  description = "${var.project_name} codebuild project assume roles"
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    actions = [
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]

    resources = [
      "${module.pr_builder_bucket.arn}/*/build_outp/*"
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
    ]

    resources = [
      "${module.pr_builder_bucket.arn}/*/source_out/*"
    ]
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
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    #TODO: Investigate CloudTrail to narrow this down
    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:CreateNetworkInterfacePermission",
    ]
    resources = [
      "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values = [
        "codebuild.amazonaws.com"
      ]
    }

    condition {
      test     = "ArnEquals"
      variable = "ec2:Subnet"
      values   = var.vpc_config.private_subnet_arns
    }
  }

  statement {
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]

    resources = [
      module.pr_builder_bucket.kms_key_arn
    ]
  }
}

resource "aws_iam_policy" "codebuild_policy" {
  name_prefix = substr(var.project_name, 0, 32)
  description = "${var.project_name} build"
  policy      = data.aws_iam_policy_document.codebuild_policy.json

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    codebuild_project = var.project_name
  }
}

resource "aws_iam_role" "build" {
  name_prefix         = substr(var.project_name, 0, 32)
  description         = "${var.project_name} build"
  assume_role_policy  = data.aws_iam_policy_document.codebuild_assume_role.json
  managed_policy_arns = local.managed_policy_arns

  tags = {
    Step = var.project_name
  }
}