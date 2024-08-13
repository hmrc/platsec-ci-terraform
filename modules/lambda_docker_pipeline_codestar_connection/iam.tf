data "aws_iam_policy_document" "codeconnections" {
  statement {
    # Have to add both for a short period. AWS "say" they've moved to codeconnections, but it still createted a codestar connection
    actions = [
      "codeconnections:UseConnection",
      "codestar-connections:UseConnection",
    ]

    resources = [
      aws_codestarconnections_connection.connection.arn
    ]

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "codeconnections:FullRepositoryId"
      values = [
        "${var.src_org}/${var.src_repo}"
      ]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "codestar-connections:FullRepositoryId"
      values = [
        "${var.src_org}/${var.src_repo}"
      ]
    }
  }
}

resource "aws_iam_policy" "codeconnections" {
  name_prefix = "platsec-ci-codeconnections"
  description = "${var.pipeline_name} allows and restricts use to desired repo ${var.src_repo}"
  policy      = data.aws_iam_policy_document.codeconnections.json

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Pipeline = var.pipeline_name
  }
}