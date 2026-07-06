
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "secretsmanager" {
  statement {
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      data.aws_secretsmanager_secret_version.github_token.arn
    ]
  }
}

resource "aws_iam_policy" "secretsmanager" {
  name_prefix = substr(var.pipeline_name, 0, 32)
  description = "${var.pipeline_name} get secrets from secrets manager"
  policy      = data.aws_iam_policy_document.secretsmanager.json

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({
    Pipeline = var.pipeline_name
  }, var.tags)
}

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

  name_prefix = substr(var.pipeline_name, 0, 32)
  description = "${var.pipeline_name} push images to ECR"
  policy      = data.aws_iam_policy_document.ecr_push[0].json

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({
    Pipeline = var.pipeline_name
  }, var.tags)
}
