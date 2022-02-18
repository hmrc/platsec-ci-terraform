locals {
  logs_access_roles = [
    "arn:aws:iam::${var.account_id}:role/RoleSecurityEngineer",
  ]
}

module "access_logs" {
  source         = "hmrc/s3-bucket-core/aws"
  version        = "0.1.1"
  bucket_name    = var.bucket_name
  force_destroy  = false
  kms_key_policy = null

  data_expiry      = "90-days"
  data_sensitivity = "low"

  log_bucket_id = var.bucket_name
}

#data "aws_iam_policy_document" "kms" {
#  statement {
#    sid = "Allow-IAM"
#    effect = "Allow"
#    actions = [
#      "kms:*"
#    ]
#    resources = [
#      "*"
#    ]
#    principals {
#      identifiers = ["arn:aws:iam::${var.account_id}:root"]
#      type        = "AWS"
#    }
#
#  }
#}

resource "aws_s3_bucket_policy" "access_logs" {
  bucket     = module.access_logs.id
  policy     = data.aws_iam_policy_document.access_logs.json
  depends_on = [module.access_logs]
}

data "aws_iam_policy_document" "access_logs" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = ["${module.access_logs.arn}/*"]
  }

  statement {
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl",
    ]
    resources = [module.access_logs.arn]
  }

  statement {
    sid = "Administer"
    principals {
      identifiers = ["arn:aws:iam::${var.account_id}:role/RoleTerraformProvisioner"]
      type        = "AWS"
    }
    actions = [
      "s3:*",
    ]
    resources = [
      module.access_logs.arn,
      "${module.access_logs.arn}/*",
    ]
  }

  statement {
    sid = "LogsAccess"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    actions = [
      "s3:ListBucket*",
      "s3:GetObject*",
      "s3:ListMultipartUploadParts",
    ]
    resources = [
      module.access_logs.arn,
      "${module.access_logs.arn}/*"
    ]
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = local.logs_access_roles
    }
  }
}

