
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

resource "aws_iam_role" "upload" {
  name                = "${var.name_prefix}-upload"
  assume_role_policy  = data.aws_iam_policy_document.codebuild_assume_role.json
  managed_policy_arns = var.policy_arns
}
