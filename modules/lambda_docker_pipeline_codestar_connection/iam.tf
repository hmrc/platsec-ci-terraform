data "aws_iam_policy_document" "codeconnections" {
  statement {
    actions = [
      "codeconnections:UseConnection",
    ]

    resources = [
      aws_codestarconnections_connection.connection.arn
    ]

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "codeconnections:FullRepositoryId"
      values = [
        var.src_repo
      ]
    }
  }
}

resource "aws_iam_policy" "codeconnections" {
  name_prefix = "platsec-ci-codeconnections"
  description = "${var.pipeline_name} allows and resticts use to desired repo ${var.src_repo}"
  policy      = data.aws_iam_policy_document.codeconnections.json

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Pipeline = var.pipeline_name
  }
}