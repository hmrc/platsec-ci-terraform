# The key value is set outside Terraform by the credentials rotation process in platsec-utils.
resource "aws_secretsmanager_secret" "psbuildmdtp_gpg_private_key" {
  description = "Secrets Manager secret for the psbuildmdtp GPG private key"
  name        = "psbuildmdtp_gpg_private_key"
  kms_key_id  = aws_kms_key.psbuildmdtp_gpg_private_key.arn
}

resource "aws_secretsmanager_secret_policy" "psbuildmdtp_gpg_private_key" {
  secret_arn = aws_secretsmanager_secret.psbuildmdtp_gpg_private_key.arn
  policy     = data.aws_iam_policy_document.github_credentials_secret.json
}

module "psbuildmdtp_gpg_private_key_kms_policy" {
  source = "../modules/kms_key_policy"

  read_roles     = concat(local.github_credentials_consumer_role_arns, local.readers)
  describe_roles = local.github_credentials_consumer_terraform_role_arns
  write_roles    = local.writers
  admin_roles    = local.admins
}

resource "aws_kms_key" "psbuildmdtp_gpg_private_key" {
  description             = "Key for the psbuildmdtp_gpg_private_key secret"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  rotation_period_in_days = 90
  policy                  = module.psbuildmdtp_gpg_private_key_kms_policy.policy_document_json
}

resource "aws_kms_alias" "psbuildmdtp_gpg_private_key" {
  name          = "alias/psbuildmdtp-gpg-private-key"
  target_key_id = aws_kms_key.psbuildmdtp_gpg_private_key.id
}
