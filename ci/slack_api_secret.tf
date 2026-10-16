locals {
  slack_v2_api_key_secret_name = "service_accounts/slack_v2_api_key"

  slack_v2_api_key_consumers = {
    sandbox = {
      account_id = nonsensitive(data.aws_secretsmanager_secret_version.sandbox_account_id.secret_string)
      role_names = ["cloudtrail-events-monitor-lambda-lambda"]
    }
    development = {
      account_id = nonsensitive(data.aws_secretsmanager_secret_version.development_account_id.secret_string)
      role_names = [
        "cloudtrail-events-monitor-lambda-lambda",
        "grant-user-accessac995255c6e7e150c6aa04ebbe",
      ]
    }
    production = {
      account_id = nonsensitive(data.aws_secretsmanager_secret_version.production_account_id.secret_string)
      role_names = ["cloudtrail-events-monitor-lambda-lambda"]
    }
    auth = {
      account_id = nonsensitive(data.aws_secretsmanager_secret_version.auth_account_id.secret_string)
      role_names = ["grant-user-access20230727085907634600000001"]
    }
  }

  slack_v2_api_key_consumer_account_ids = [
    for consumer in values(local.slack_v2_api_key_consumers) : consumer.account_id
  ]

  slack_v2_api_key_consumer_runtime_role_arns = flatten([
    for consumer in values(local.slack_v2_api_key_consumers) : [
      for role_name in consumer.role_names : "arn:aws:iam::${consumer.account_id}:role/${role_name}"
    ]
  ])

  slack_v2_api_key_consumer_applier_role_arns = formatlist("arn:aws:iam::%s:role/RoleTerraformApplier", local.slack_v2_api_key_consumer_account_ids)
  slack_v2_api_key_consumer_planner_role_arns = formatlist("arn:aws:iam::%s:role/RoleTerraformPlanner", local.slack_v2_api_key_consumer_account_ids)

  slack_v2_api_key_consumer_role_arns = concat(
    local.slack_v2_api_key_consumer_runtime_role_arns,
    local.slack_v2_api_key_consumer_applier_role_arns,
  )

  slack_v2_api_key_consumer_terraform_role_arns = concat(
    local.slack_v2_api_key_consumer_applier_role_arns,
    local.slack_v2_api_key_consumer_planner_role_arns,
  )
}

resource "aws_secretsmanager_secret" "slack_v2_api_key" {
  name                    = local.slack_v2_api_key_secret_name
  description             = "Slack API key used by the cloudtrail-events-monitor lambda"
  kms_key_id              = aws_kms_key.slack_v2_api_key.arn
  recovery_window_in_days = 30
}

data "aws_iam_policy_document" "slack_v2_api_key" {
  statement {
    sid    = "AllowCrossAccountLambdaRead"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.slack_v2_api_key_consumer_account_ids
    }

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]

    resources = ["*"]

    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = local.slack_v2_api_key_consumer_role_arns
    }
  }

  statement {
    sid    = "AllowCrossAccountTerraformDescribe"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.slack_v2_api_key_consumer_account_ids
    }

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
    ]

    resources = ["*"]

    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = local.slack_v2_api_key_consumer_terraform_role_arns
    }
  }

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["secretsmanager:*"]
    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_secretsmanager_secret_policy" "slack_v2_api_key" {
  secret_arn = aws_secretsmanager_secret.slack_v2_api_key.arn
  policy     = data.aws_iam_policy_document.slack_v2_api_key.json
}

# Placeholder version only; the real value is set out of band and must never be committed
resource "aws_secretsmanager_secret_version" "slack_v2_api_key" {
  secret_id     = aws_secretsmanager_secret.slack_v2_api_key.id
  secret_string = "PLACEHOLDER"

  lifecycle {
    ignore_changes = [secret_string]
  }
}
