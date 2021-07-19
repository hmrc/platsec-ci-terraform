resource "aws_ecr_repository" "lambda" {
  name = local.full_name
}

data "aws_iam_policy_document" "cross_account_read" {
  statement {
    principals {
      identifiers = [
        //        "arn:aws:iam::${var.sandbox_deploy.account_id}:root", # todo add sandbox
        "arn:aws:iam::${var.development_deploy.account_id}:root",
        //        "arn:aws:iam::${var.production_deploy.account_id}:root" # todo add prod
      ]
      type = "AWS"
    }
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]
  }
}

resource "aws_ecr_repository_policy" "example" {
  policy     = data.aws_iam_policy_document.cross_account_read.json
  repository = aws_ecr_repository.lambda.name
}
