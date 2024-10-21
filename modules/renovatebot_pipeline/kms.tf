data "aws_iam_policy_document" "kms" {
  statement {
    sid       = "RenovateAllowPermissionsIamUsers"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      type        = "AWS"
    }
  }

  statement {
    sid = "RenovateAllowPermissionsPipelineRoles"
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = ["*"]
    principals {
      identifiers = var.admin_roles
      type        = "AWS"
    }
  }
}

resource "aws_kms_key" "this" {
  bypass_policy_lockout_safety_check = false
  deletion_window_in_days            = 7
  enable_key_rotation                = true
  rotation_period_in_days            = 90
  policy                             = data.aws_iam_policy_document.kms.json
}

resource "aws_kms_alias" "this" {
  name_prefix   = "alias/${local.name}"
  target_key_id = aws_kms_key.this.id
}