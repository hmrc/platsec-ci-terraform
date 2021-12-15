resource "aws_sns_topic" "platsec_compliance_alerting_failure_topic" {
  name         = "platsec_compliance_alerting_failure_topic"
  display_name = "platsec_compliance_alerting_failure_topic"
  policy       = ""
}

resource "aws_sns_topic_policy" "platsec_compliance_alerting_failure_topic_policy" {
  arn    = aws_sns_topic.platsec_compliance_alerting_failure_topic.arn
  policy = data.aws_iam_policy_document.platsec_compliance_alerting_failure_topic_policy_doc.json
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  for_each  = tomap(local.accounts)
  topic_arn = aws_sns_topic.platsec_compliance_alerting_failure_topic.arn
  protocol  = "lambda"
  endpoint = "arn:aws:lambda:eu-west-2:${each.value.id}:function:platsec_compliance_alerting_lambda"
}

resource "aws_lambda_permission" "pipeline_notification" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "platsec_compliance_alerting_lambda"
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.platsec_compliance_alerting_failure_topic.arn
}

data "aws_iam_policy_document" "platsec_compliance_alerting_failure_topic_policy_doc" {
  statement {
    sid = "CodestarPublish"
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.platsec_compliance_alerting_failure_topic.arn,
    ]
  }

  statement {
    sid = "SnsTopicSubscriptionCondition"

    principals {
      type = "AWS"
      identifiers = [ "*" ]
    }

    actions = [
      "sns:Subscribe"
    ]

    resources = [
      aws_sns_topic.platsec_compliance_alerting_failure_topic.arn,
    ]

    condition {
      test     = "StringLike"
      variable = "SNS:Endpoint"
      values = [ "*@digital.hmrc.gov.uk"]
    }
  }

}

output "sns_arn" {
  value = aws_sns_topic.platsec_compliance_alerting_failure_topic.arn
}
