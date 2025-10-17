module "cloudwatch_kms" {
  source = "../new_kms_key_policy"

  read_services = ["logs.${data.aws_region.current.name}.amazonaws.com"]
  read_service_conditions = [
    {
      test     = "ArnLike",
      variable = "kms:EncryptionContext:aws:logs:arn",
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
  ]

  write_services = ["logs.${data.aws_region.current.name}.amazonaws.com"]
  write_service_conditions = [
    {
      test     = "ArnLike",
      variable = "kms:EncryptionContext:aws:logs:arn",
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
  ]
}

resource "aws_kms_key" "cloudwatch" {
  policy                  = module.cloudwatch_kms.policy_document_json
  enable_key_rotation     = true
  description             = "KMS key for CloudWatch logs for ${var.name} CodeBuild project"
  deletion_window_in_days = 30
  rotation_period_in_days = 90
}

resource "aws_kms_alias" "cloudwatch" {
  name_prefix   = "alias/${var.name}-cloudwatch-"
  target_key_id = aws_kms_key.cloudwatch.key_id
}

resource "aws_cloudwatch_log_group" "build" {
  name_prefix       = var.name
  retention_in_days = 365
  kms_key_id        = aws_kms_alias.cloudwatch.target_key_id
  tags              = var.tags
}