locals {
  github_admin_tool_token_secret_name = "github-admin-tool-token"

  # Accounts that need access to the GitHub admin tool token
  github_admin_tool_token_consumer_account_ids = [
    nonsensitive(data.aws_secretsmanager_secret_version.development_account_id.secret_string),
    nonsensitive(data.aws_secretsmanager_secret_version.production_account_id.secret_string),
  ]

  github_admin_tool_token_consumer_role_arns = [
    for account_id in local.github_admin_tool_token_consumer_account_ids :
    "arn:aws:iam::${account_id}:role/platsec-scanner-jer-*"
  ]

  # Roles allowed to retrieve and describe the secret.
  github_admin_tool_token_consumer_read_role_arns = concat(
    local.github_admin_tool_token_consumer_role_arns,
    formatlist(
      "arn:aws:iam::%s:role/RoleTerraformApplier",
      local.github_admin_tool_token_consumer_account_ids
    ),
  )

  # Roles allowed to inspect the secret policy and metadata.
  github_admin_tool_token_consumer_terraform_role_arns = concat(
    formatlist(
      "arn:aws:iam::%s:role/RoleTerraformApplier",
      local.github_admin_tool_token_consumer_account_ids
    ),
    formatlist(
      "arn:aws:iam::%s:role/RoleTerraformPlanner",
      local.github_admin_tool_token_consumer_account_ids
    ),
  )
}

resource "aws_secretsmanager_secret" "github_admin_tool_token" {
  name                    = local.github_admin_tool_token_secret_name
  description             = "GitHub PAT used by the platsec-scanner admin and webhook detectors"
  kms_key_id              = aws_kms_key.github_admin_tool_token.arn
  recovery_window_in_days = 30
}

data "aws_iam_policy_document" "github_admin_tool_token" {
  statement {
    sid    = "AllowCrossAccountRead"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.github_admin_tool_token_consumer_account_ids
    }

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]

    resources = ["*"]

    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = local.github_admin_tool_token_consumer_read_role_arns
    }
  }

  statement {
    sid    = "AllowCrossAccountTerraformDescribe"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.github_admin_tool_token_consumer_account_ids
    }

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
    ]

    resources = ["*"]

    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = local.github_admin_tool_token_consumer_terraform_role_arns
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

resource "aws_secretsmanager_secret_policy" "github_admin_tool_token" {
  secret_arn = aws_secretsmanager_secret.github_admin_tool_token.arn
  policy     = data.aws_iam_policy_document.github_admin_tool_token.json
}

# Placeholder version only; the real value is set out of band and must never be committed
resource "aws_secretsmanager_secret_version" "github_admin_tool_token" {
  secret_id     = aws_secretsmanager_secret.github_admin_tool_token.id
  secret_string = "PLACEHOLDER"

  lifecycle {
    ignore_changes = [secret_string]
  }
}
