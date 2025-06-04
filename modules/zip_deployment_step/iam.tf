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
    actions   = ["sts:AssumeRole"]
    resources = [var.deployment_role_arn]
  }
}

resource "aws_iam_policy" "deploy" {
  name_prefix = substr(var.step_name, 0, 32)
  description = "${var.step_name} deploy"
  policy      = data.aws_iam_policy_document.deploy.json

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({
    Step = var.step_name
  }, var.tags)
}

resource "aws_iam_role" "deploy" {
  name_prefix        = substr(var.step_name, 0, 32)
  description        = "${var.step_name} deploy"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  managed_policy_arns = [
    var.build_core_policy_arn,
    aws_iam_policy.deploy.arn
  ]

  tags = merge({
    Step = var.step_name
  }, var.tags)
}
