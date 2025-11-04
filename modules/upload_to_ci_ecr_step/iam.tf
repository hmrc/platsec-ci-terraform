
data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    principals {
      identifiers = ["codebuild.amazonaws.com"]
      type        = "Service"
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "deploy" {
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeImages",
      "ecr:PutImage"
    ]
    resources = [var.ecr_arn]
  }
}

resource "aws_iam_policy" "deploy" {
  name_prefix = substr(var.step_name, 0, 32)
  description = "${var.step_name} deploy"
  policy      = data.aws_iam_policy_document.deploy.json

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Step = var.step_name
  }
}

resource "aws_iam_role" "deploy" {
  name_prefix        = substr(var.step_name, 0, 32)
  description        = "${var.step_name} deploy"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json

  tags = merge({
    Step = var.step_name
  }, var.tags)
}

resource "aws_iam_role_policy_attachment" "managed_policy" {
  for_each   = toset(concat([var.build_core_policy_arn], [aws_iam_policy.deploy.arn]))
  role       = aws_iam_role.deploy.name
  policy_arn = each.value
}
