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

  slack_v2_api_key_consumer_planner_role_arns = formatlist("arn:aws:iam::%s:role/RoleTerraformPlanner", local.slack_v2_api_key_consumer_account_ids)

  slack_v2_api_key_consumer_terraform_role_arns = concat(
    formatlist("arn:aws:iam::%s:role/RoleTerraformApplier", local.slack_v2_api_key_consumer_account_ids),
    formatlist("arn:aws:iam::%s:role/RoleTerraformPlanner", local.slack_v2_api_key_consumer_account_ids)
  )

  external_github_token_secret_name = "service_accounts/external_github_token"

  # Accounts that need access to the external GitHub token
  external_github_token_consumer_account_ids = [
    nonsensitive(data.aws_secretsmanager_secret_version.development_account_id.secret_string),
    nonsensitive(data.aws_secretsmanager_secret_version.production_account_id.secret_string),
  ]

  # Cross-account IAM role ARNs for the external GitHub token.
  development_platsec_scanner_role_arn = "arn:aws:iam::${local.external_github_token_consumer_account_ids[0]}:role/platsec-scanner-jer-*"
  production_platsec_scanner_role_arn  = "arn:aws:iam::${local.external_github_token_consumer_account_ids[1]}:role/platsec-scanner-jer-*"

  external_github_token_consumer_role_arns = [
    local.development_platsec_scanner_role_arn,
    local.production_platsec_scanner_role_arn,
  ]

  # Roles allowed to retrieve and describe the secret.
  external_github_token_consumer_read_role_arns = concat(
    local.external_github_token_consumer_role_arns,
    formatlist(
      "arn:aws:iam::%s:role/RoleTerraformApplier",
      local.external_github_token_consumer_account_ids
    ),
  )

  # Roles allowed to inspect the secret policy and metadata.
  external_github_token_consumer_terraform_role_arns = concat(
    formatlist(
      "arn:aws:iam::%s:role/RoleTerraformApplier",
      local.external_github_token_consumer_account_ids
    ),
    formatlist(
      "arn:aws:iam::%s:role/RoleTerraformPlanner",
      local.external_github_token_consumer_account_ids
    ),
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

resource "aws_secretsmanager_secret" "external_github_token" {
  name                    = local.external_github_token_secret_name
  description             = "External GitHub token used for CI/CD operations"
  kms_key_id              = aws_kms_key.external_github_token.arn
  recovery_window_in_days = 30
}

data "aws_iam_policy_document" "external_github_token" {
  statement {
    sid    = "AllowCrossAccountRead"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.external_github_token_consumer_account_ids
    }

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]

    resources = ["*"]

    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = local.external_github_token_consumer_role_arns
    }
  }

  statement {
    sid    = "AllowCrossAccountTerraformDescribe"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.external_github_token_consumer_account_ids
    }

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
    ]

    resources = ["*"]

    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = local.external_github_token_consumer_terraform_role_arns
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

resource "aws_secretsmanager_secret_policy" "external_github_token" {
  secret_arn = aws_secretsmanager_secret.external_github_token.arn
  policy     = data.aws_iam_policy_document.external_github_token.json
}

# Placeholder version only; the real value is set out of band and must never be committed
resource "aws_secretsmanager_secret_version" "external_github_token" {
  secret_id     = aws_secretsmanager_secret.external_github_token.id
  secret_string = "PLACEHOLDER"

  lifecycle {
    ignore_changes = [secret_string]
  }
}