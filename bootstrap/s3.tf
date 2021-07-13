resource "aws_s3_bucket" "s3_bucket" {
  bucket_prefix = var.boostrap_name
  acl           = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.terraform_key.key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    data_sensitivity = "high"
    allow_delete     = false
  }

  lifecycle_rule {
    id                                     = "AbortIncompleteMultipartUpload"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 7
  }

  lifecycle_rule {
    id      = "version_expiration"
    enabled = true

    # If versioning is set, expire all non-current at 90 days
    noncurrent_version_expiration {
      days = 90
    }
  }
}
