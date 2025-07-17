locals {
  bucket_name           = "ci-${substr(var.project_name, 0, 32)}"
  access_logs_bucket_id = var.access_logs_bucket_id
  readers = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformPlanner",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleProwlerScanner",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.project_role_name}*",
  ]
  writers = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformApplier",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer",
  ]
  admins = concat(var.admin_roles, ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleKmsAdministrator"])
}

module "kms_key_policy_document" {
  source = "../kms_key_policy"

  read_roles  = local.readers
  write_roles = local.writers
  admin_roles = local.admins
}

module "pr_builder_bucket" {
  source         = "hmrc/s3-bucket-core/aws"
  version        = "1.2.0"
  bucket_name    = local.bucket_name
  force_destroy  = true
  kms_key_policy = module.kms_key_policy_document.policy_document_json

  data_expiry      = "90-days"
  data_sensitivity = "low"

  transition_to_glacier_days = var.transition_to_glacier_days

  log_bucket_id = local.access_logs_bucket_id
  tags = merge({
    codebuild_project = var.project_name
  }, var.tags)
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = module.pr_builder_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:*",
    ]
    resources = [
      module.pr_builder_bucket.arn,
      "${module.pr_builder_bucket.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "DenyAdminActivities"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:DeleteBucket*",
      "s3:GetAccelerateConfiguration",
      "s3:GetAnalyticsConfiguration",
      "s3:GetInventoryConfiguration",
      "s3:GetMetricsConfiguration",
      "s3:PutAccelerateConfiguration",
      "s3:PutAnalyticsConfiguration",
      "s3:PutBucket*",
      "s3:PutEncryptionConfiguration",
      "s3:PutInventoryConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:PutMetricsConfiguration",
      "s3:PutReplicationConfiguration",
    ]
    resources = [module.pr_builder_bucket.arn]
    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values   = var.admin_roles
    }
  }

  statement {
    sid    = "DenyActivitiesUnlessBucketAdmin"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetInventoryConfiguration",
      "s3:GetMetricsConfiguration",
      "s3:GetReplicationConfiguration",
    ]
    resources = [module.pr_builder_bucket.arn]
    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values   = concat(var.admin_roles, ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleProwlerScanner"])
    }
  }

  statement {
    sid    = "AllowReadOnlyProwlerScanner"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:ListBucket*",
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:GetEncryptionConfiguration",
      "s3:GetInventoryConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetMetricsConfiguration",
      "s3:GetReplicationConfiguration"
    ]
    resources = [
      module.pr_builder_bucket.arn,
      "${module.pr_builder_bucket.arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleProwlerScanner"]
    }
  }
}
