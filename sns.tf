resource "aws_sns_topic" "platsec_compliance_alerting_failure_topic" {
  name         = "platsec_compliance_alerting_failure_topic"
  display_name = "platsec_compliance_alerting_failure_topic"
  policy       = ""
}

resource "aws_sns_topic_policy" "platsec_compliance_alerting_failure_topic_policy" {
  arn    = aws_sns_topic.platsec_compliance_alerting_failure_topic.arn
  policy = data.aws_iam_policy_document.platsec_compliance_alerting_failure_topic_policy_doc.json
}

#resource "aws_lambda_permission" "pipeline_notification" {
#  statement_id  = "AllowExecutionFromSNS"
#  action        = "lambda:InvokeFunction"
#  function_name = "platsec_compliance_alerting_lambda"
#  principal     = "sns.amazonaws.com"
#  source_arn    = aws_sns_topic.platsec_compliance_alerting_failure_topic.arn
#}

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
      identifiers = ["*"]
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

  statement {
    sid = "AllowSubscriptionsFromOtherAccounts"

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${local.accounts.sandbox.id}:root"
      ]
    }

    actions = [
      "SNS:Subscribe",
      "SNS:Receive",
    ]

    effect = "Allow"

    resources = [ aws_sns_topic.platsec_compliance_alerting_failure_topic.arn ]
  }

}

output "sns_arn" {
  value = aws_sns_topic.platsec_compliance_alerting_failure_topic.arn
}
