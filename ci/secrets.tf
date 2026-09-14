locals {
  slack_v2_api_key_secret_name = "service_accounts/slack_v2_api_key"

  # Accounts running the cloudtrail-events-monitor lambda that read the shared Slack credential
  slack_v2_api_key_consumer_account_ids = [
    nonsensitive(data.aws_secretsmanager_secret_version.sandbox_account_id.secret_string),
    nonsensitive(data.aws_secretsmanager_secret_version.development_account_id.secret_string),
    nonsensitive(data.aws_secretsmanager_secret_version.production_account_id.secret_string),
  ]

  slack_v2_api_key_consumer_role_arns = concat(
    formatlist("arn:aws:iam::%s:role/cloudtrail-events-monitor-lambda-lambda", local.slack_v2_api_key_consumer_account_ids),
    formatlist("arn:aws:iam::%s:role/RoleTerraformApplier", local.slack_v2_api_key_consumer_account_ids)
  )
}

module "slack_v2_api_key_kms_policy" {
  source = "../modules/kms_key_policy"

  read_roles = concat(
    local.slack_v2_api_key_consumer_role_arns,
    [
      local.terraform_planner_role,
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleProwlerScanner",
    ]
  )

  describe_roles = formatlist("arn:aws:iam::%s:role/RoleTerraformPlanner", local.slack_v2_api_key_consumer_account_ids)

  write_roles = [
    local.terraform_applier_role,
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer",
  ]

  admin_roles = [
    local.terraform_applier_role,
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleKmsAdministrator",
  ]
}

resource "aws_kms_key" "slack_v2_api_key" {
  description                        = "Encrypts the shared ${local.slack_v2_api_key_secret_name} secret"
  bypass_policy_lockout_safety_check = false
  deletion_window_in_days            = 30
  enable_key_rotation                = true
  rotation_period_in_days            = 90
  policy                             = module.slack_v2_api_key_kms_policy.policy_document_json
}

resource "aws_kms_alias" "slack_v2_api_key" {
  name          = "alias/service_accounts_slack_v2_api_key"
  target_key_id = aws_kms_key.slack_v2_api_key.id
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
