locals {
  pagerduty_live_services_key_secret_name = "pagerduty/platform_live_services_key"
  pagerduty_lab_services_key_secret_name  = "pagerduty/platform_lab_services_key"

  # Includes platsec-development and central-audit-development because some of their modules
  # (batch_platsec_scanner, batch_prowler_scanner, vpc_flow_logs_splunk) always page Live regardless of environment.
  pagerduty_live_services_key_consumer_account_ids = [
    nonsensitive(data.aws_secretsmanager_secret_version.central_audit_production_account_id.secret_string),
    nonsensitive(data.aws_secretsmanager_secret_version.production_account_id.secret_string),
    nonsensitive(data.aws_secretsmanager_secret_version.development_account_id.secret_string),
    nonsensitive(data.aws_secretsmanager_secret_version.central_audit_development_account_id.secret_string),
  ]

  pagerduty_lab_services_key_consumer_account_ids = [
    nonsensitive(data.aws_secretsmanager_secret_version.development_account_id.secret_string),
    nonsensitive(data.aws_secretsmanager_secret_version.sandbox_account_id.secret_string),
    nonsensitive(data.aws_secretsmanager_secret_version.central_audit_development_account_id.secret_string),
    nonsensitive(data.aws_secretsmanager_secret_version.central_audit_production_account_id.secret_string),
  ]

  pagerduty_live_services_key_consumer_applier_role_arns = formatlist("arn:aws:iam::%s:role/RoleTerraformApplier", local.pagerduty_live_services_key_consumer_account_ids)
  pagerduty_live_services_key_consumer_planner_role_arns = formatlist("arn:aws:iam::%s:role/RoleTerraformPlanner", local.pagerduty_live_services_key_consumer_account_ids)

  pagerduty_live_services_key_consumer_read_role_arns = concat(
    local.pagerduty_live_services_key_consumer_applier_role_arns,
    local.pagerduty_live_services_key_consumer_planner_role_arns,
  )

  pagerduty_live_services_key_consumer_terraform_role_arns = local.pagerduty_live_services_key_consumer_read_role_arns

  pagerduty_lab_services_key_consumer_applier_role_arns = formatlist("arn:aws:iam::%s:role/RoleTerraformApplier", local.pagerduty_lab_services_key_consumer_account_ids)
  pagerduty_lab_services_key_consumer_planner_role_arns = formatlist("arn:aws:iam::%s:role/RoleTerraformPlanner", local.pagerduty_lab_services_key_consumer_account_ids)

  pagerduty_lab_services_key_consumer_read_role_arns = concat(
    local.pagerduty_lab_services_key_consumer_applier_role_arns,
    local.pagerduty_lab_services_key_consumer_planner_role_arns,
  )

  pagerduty_lab_services_key_consumer_terraform_role_arns = local.pagerduty_lab_services_key_consumer_read_role_arns
}

resource "aws_secretsmanager_secret" "pagerduty_live_services_key" {
  name                    = local.pagerduty_live_services_key_secret_name
  description             = "PagerDuty routing key for the Live service"
  kms_key_id              = aws_kms_key.pagerduty_live_services_key.arn
  recovery_window_in_days = 30
}

data "aws_iam_policy_document" "pagerduty_live_services_key" {
  statement {
    sid    = "AllowCrossAccountRead"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.pagerduty_live_services_key_consumer_account_ids
    }

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]

    resources = ["*"]

    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = local.pagerduty_live_services_key_consumer_read_role_arns
    }
  }

  statement {
    sid    = "AllowCrossAccountTerraformDescribe"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.pagerduty_live_services_key_consumer_account_ids
    }

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
    ]

    resources = ["*"]

    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = local.pagerduty_live_services_key_consumer_terraform_role_arns
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

resource "aws_secretsmanager_secret_policy" "pagerduty_live_services_key" {
  secret_arn = aws_secretsmanager_secret.pagerduty_live_services_key.arn
  policy     = data.aws_iam_policy_document.pagerduty_live_services_key.json
}

# Placeholder version only;
resource "aws_secretsmanager_secret_version" "pagerduty_live_services_key" {
  secret_id     = aws_secretsmanager_secret.pagerduty_live_services_key.id
  secret_string = "PLACEHOLDER"

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret" "pagerduty_lab_services_key" {
  name                    = local.pagerduty_lab_services_key_secret_name
  description             = "PagerDuty routing key for the Labs service"
  kms_key_id              = aws_kms_key.pagerduty_lab_services_key.arn
  recovery_window_in_days = 30
}

data "aws_iam_policy_document" "pagerduty_lab_services_key" {
  statement {
    sid    = "AllowCrossAccountRead"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.pagerduty_lab_services_key_consumer_account_ids
    }

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]

    resources = ["*"]

    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = local.pagerduty_lab_services_key_consumer_read_role_arns
    }
  }

  statement {
    sid    = "AllowCrossAccountTerraformDescribe"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.pagerduty_lab_services_key_consumer_account_ids
    }

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
    ]

    resources = ["*"]

    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = local.pagerduty_lab_services_key_consumer_terraform_role_arns
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

resource "aws_secretsmanager_secret_policy" "pagerduty_lab_services_key" {
  secret_arn = aws_secretsmanager_secret.pagerduty_lab_services_key.arn
  policy     = data.aws_iam_policy_document.pagerduty_lab_services_key.json
}

# Placeholder version only;
resource "aws_secretsmanager_secret_version" "pagerduty_lab_services_key" {
  secret_id     = aws_secretsmanager_secret.pagerduty_lab_services_key.id
  secret_string = "PLACEHOLDER"

  lifecycle {
    ignore_changes = [secret_string]
  }
}
