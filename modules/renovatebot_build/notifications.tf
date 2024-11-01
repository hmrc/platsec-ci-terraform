resource "aws_codestarnotifications_notification_rule" "fail" {
  detail_type = "FULL"
  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-failed"
  ]

  name     = local.name
  resource = "arn:aws:codepipeline:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${local.name}"

  target {
    address = var.sns_topic_arn
  }

  tags = var.tags
}