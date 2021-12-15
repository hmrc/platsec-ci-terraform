resource "aws_codestarnotifications_notification_rule" "ua_platsec_compliance_alerting_failed_codepipeline" {
  detail_type    = "FULL"
  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-failed"
  ]

  name     = local.pipeline_name
  resource = "arn:aws:codepipeline:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${local.pipeline_name}"

  target {
    address = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:platsec_compliance_alerting_failure_topic"
#    data.aws_sns_topic.platsec_compliance_alerting_failure_topic.arn
  }

#  depends_on = [data.aws_sns_topic.platsec_compliance_alerting_failure_topic.arn]

}
