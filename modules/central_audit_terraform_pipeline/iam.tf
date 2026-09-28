
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "ecr_push" {
  count = length(var.ecr_push_repository_arns) == 0 ? 0 : 1

  statement {
    sid       = "GetAuthorizationToken"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "PushImages"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
    resources = var.ecr_push_repository_arns
  }
}

resource "aws_iam_policy" "ecr_push" {
  count = length(var.ecr_push_repository_arns) == 0 ? 0 : 1

  # Static name so the ARN is known at plan time (see ecr_push_policy_arns local in build.tf).
  name        = "${var.pipeline_name}-ecr-push"
  description = "${var.pipeline_name} push images to ECR"
  policy      = data.aws_iam_policy_document.ecr_push[0].json

  tags = merge({
    Pipeline = var.pipeline_name
  }, var.tags)
}
