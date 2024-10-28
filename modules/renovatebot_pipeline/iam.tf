data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
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

    resources = ["*"]
  }

  statement {
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = [aws_kms_key.this.arn]
  }

  statement {
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    resources = [
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:/github/*"
    ]
  }

  statement {
    actions   = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"
      values   = formatlist("arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:subnet/%s", var.vpc_config.private_subnet_ids)
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    actions = [
      "codeconnections:GetConnection",
      "codeconnections:GetConnectionToken",
      "codeconnections:UseConnection",
    ]

    resources = [
      var.codeconnection_arn
    ]

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "codeconnections:FullRepositoryId"
      values   = var.repositories
    }
  }

  statement {
    actions = [
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    # will refine via ct logs, no information on reqs as of yet
    resources = [ "*" ]
  }
}

resource "aws_iam_policy" "codebuild_policy" {
  policy      = data.aws_iam_policy_document.codebuild_policy.json
  name_prefix = local.name
}

resource "aws_iam_role" "codebuild_role" {
  name_prefix        = local.name
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.codebuild_policy.id
  ]
  tags = var.tags
}

data "aws_iam_policy_document" "events_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "schedule_policy" {
  statement {
    actions = [
      "codebuild:StartBuild"
    ]

    resources = [
      aws_codebuild_project.this.arn
    ]
  }
}

resource "aws_iam_policy" "schedule_policy" {
  policy      = data.aws_iam_policy_document.schedule_policy.json
  name_prefix = local.name
}

resource "aws_iam_role" "schedule_role" {
  name_prefix        = local.name
  assume_role_policy = data.aws_iam_policy_document.events_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.schedule_policy.id
  ]
  tags = var.tags
}