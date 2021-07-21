
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

data "aws_iam_policy_document" "deploy" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [var.deployment_role_arn]
  }
}

resource "aws_iam_policy" "deploy" {
  name_prefix = "${var.name_prefix}-deploy"
  policy      = data.aws_iam_policy_document.deploy.json

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "deploy" {
  name               = "${var.name_prefix}-deploy"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  managed_policy_arns = [
    var.build_core_policy_arn,
    aws_iam_policy.deploy.arn
  ]
}
