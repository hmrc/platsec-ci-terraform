locals {
  # Accounts running the vault policy generator, which reads the GitHub credentials
  github_credentials_consumer_account_ids = [
    nonsensitive(data.aws_secretsmanager_secret_version.production_account_id.secret_string),
  ]

  github_credentials_consumer_role_arns = formatlist("arn:aws:iam::%s:role/vault_generator_pipeline_*_service_role", local.github_credentials_consumer_account_ids)

  github_credentials_consumer_terraform_role_arns = concat(
    formatlist("arn:aws:iam::%s:role/RoleTerraformApplier", local.github_credentials_consumer_account_ids),
    formatlist("arn:aws:iam::%s:role/RoleTerraformPlanner", local.github_credentials_consumer_account_ids)
  )
}

import {
  to = aws_secretsmanager_secret.github_api_token
  id = "arn:aws:secretsmanager:eu-west-2:987972305662:secret:/service_accounts/github_api_token-rJIRC1"
}

# The token value is set outside Terraform by the credentials rotation process in platsec-utils.
resource "aws_secretsmanager_secret" "github_api_token" {
  name       = "/service_accounts/github_api_token"
  kms_key_id = aws_kms_key.github_credentials.arn
}

resource "aws_secretsmanager_secret" "github_api_user" {
  name       = "/service_accounts/github_api_user"
  kms_key_id = aws_kms_key.github_credentials.arn
}

resource "aws_secretsmanager_secret_version" "github_api_user" {
  secret_id     = aws_secretsmanager_secret.github_api_user.id
  secret_string = "psbuildmdtp"
}

resource "aws_secretsmanager_secret_policy" "github_api_token" {
  secret_arn = aws_secretsmanager_secret.github_api_token.arn
  policy     = data.aws_iam_policy_document.github_credentials_secret.json
}

resource "aws_secretsmanager_secret_policy" "github_api_user" {
  secret_arn = aws_secretsmanager_secret.github_api_user.arn
  policy     = data.aws_iam_policy_document.github_credentials_secret.json
}

data "aws_iam_policy_document" "github_credentials_secret" {
  statement {
    sid    = "AllowCrossAccountVaultGeneratorRead"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.github_credentials_consumer_account_ids
    }

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]

    resources = ["*"]

    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = local.github_credentials_consumer_role_arns
    }
  }

  statement {
    sid    = "AllowCrossAccountTerraformDescribe"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.github_credentials_consumer_account_ids
    }

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
    ]

    resources = ["*"]

    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = local.github_credentials_consumer_terraform_role_arns
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

module "github_credentials_kms_policy" {
  source = "../modules/kms_key_policy"

  read_roles     = concat(local.github_credentials_consumer_role_arns, local.readers)
  describe_roles = local.github_credentials_consumer_terraform_role_arns
  write_roles    = local.writers
  admin_roles    = local.admins
}

resource "aws_kms_key" "github_credentials" {
  description             = "Key for the /service_accounts GitHub credentials secrets"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  rotation_period_in_days = 90
  policy                  = module.github_credentials_kms_policy.policy_document_json
}

resource "aws_kms_alias" "github_credentials" {
  name          = "alias/github-credentials"
  target_key_id = aws_kms_key.github_credentials.id
}
