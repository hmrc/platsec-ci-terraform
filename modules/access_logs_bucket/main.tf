locals {
  logs_access_roles = [
    "arn:aws:iam::${var.account_id}:role/RoleSecurityEngineer",
  ]
}

# we do not use the module 'hmrc/s3-bucket-core/aws' here as it enforces kms encryption.
# This is incompatible with s3 access logging https://docs.aws.amazon.com/AmazonS3/latest/userguide/enable-server-access-logging.html
resource "aws_s3_bucket" "access_logs" {
  bucket = var.bucket_name

  force_destroy = false

  tags = {
    Name                        = var.bucket_name
    Environment                 = terraform.workspace
    allow_delete                = "false"
    data_sensitivity            = "low"
    data_expiry                 = "90-days"
    ignore_access_logging_check = true
  }

  # lifecycle_rule {
  #   id                                     = "AbortIncompleteMultipartUpload"
  #   enabled                                = true
  #   abort_incomplete_multipart_upload_days = 7
  # }

  # lifecycle_rule {
  #   id      = "Expiration days"
  #   enabled = true

  #   expiration {
  #     days = 90
  #   }

  #   noncurrent_version_expiration {
  #     days = 90
  #   }
  # }
}

resource "aws_s3_bucket_versioning" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = ""
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket                  = aws_s3_bucket.access_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.access_logs]
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id
  rule {
    id     = "AbortIncompleteMultipartUpload"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id     = "Expiration days"
    status = "Enabled"

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "access_logs" {
  bucket     = aws_s3_bucket.access_logs.id
  policy     = data.aws_iam_policy_document.access_logs.json
  depends_on = [aws_s3_bucket.access_logs]
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
    resources = ["${aws_s3_bucket.access_logs.arn}/*"]
  }

  statement {
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl",
    ]
    resources = [aws_s3_bucket.access_logs.arn]
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
      aws_s3_bucket.access_logs.arn,
      "${aws_s3_bucket.access_logs.arn}/*",
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
      aws_s3_bucket.access_logs.arn,
      "${aws_s3_bucket.access_logs.arn}/*"
    ]
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = local.logs_access_roles
    }
  }

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
      aws_s3_bucket.access_logs.arn,
      "${aws_s3_bucket.access_logs.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
