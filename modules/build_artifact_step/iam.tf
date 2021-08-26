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

data "aws_iam_policy_document" "store_artifacts" {
  statement {
    actions = [
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]
    resources = [
      "${var.s3_bucket_arn}*build_outp/*"
    ]
  }
}
resource "aws_iam_policy" "store_artifacts" {
  name_prefix = "${var.name_prefix}-codebuild-store-artifacts"
  policy      = data.aws_iam_policy_document.store_artifacts.json

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "build" {
  name               = "${var.name_prefix}-build-artifact"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  managed_policy_arns = [
    var.build_core_policy_arn,
    aws_iam_policy.store_artifacts.arn
  ]
}
