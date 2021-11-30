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

data "aws_iam_policy_document" "build" {
  statement {
    actions = [
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]
    resources = [
      "${var.s3_bucket_arn}/*/build_outp/*"
    ]
  }
}

resource "aws_iam_policy" "store_artifacts" {
  name_prefix = substr(var.step_name, 0, 32)
  description = "${var.step_name} store artefacts"

  policy = data.aws_iam_policy_document.build.json

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Step = var.step_name
  }
}

resource "aws_iam_role" "build" {
  name_prefix        = substr(var.step_name, 0, 32)
  description        = "${var.step_name} build"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  managed_policy_arns = concat(
    [aws_iam_policy.store_artifacts.arn],
    var.policy_arns
  )

  tags = {
    Step = var.step_name
  }
}
