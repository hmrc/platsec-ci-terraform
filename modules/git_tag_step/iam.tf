
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

resource "aws_iam_role" "codebuild" {
  name_prefix        = substr(var.step_name, 0, 32)
  description        = "${var.step_name} Git Tag"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json

  tags = merge({
    Step = var.step_name
  }, var.tags)
}

resource "aws_iam_role_policy_attachment" "codebuild_managed_policy" {
  for_each   = toset(var.policy_arns)
  role       = aws_iam_role.codebuild.name
  policy_arn = each.value
}
