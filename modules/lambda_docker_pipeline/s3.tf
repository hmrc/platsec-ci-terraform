resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = local.pipeline
  acl    = "private"

  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3kmskey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = false
    expiration {
      days = 90
    }
    noncurrent_version_expiration {
      days = 90
    }
  }

  tags = {
    Pipeline = local.pipeline
  }
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket" {
  bucket                  = aws_s3_bucket.codepipeline_bucket.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_kms_key" "s3kmskey" {}

resource "aws_kms_alias" "s3kmskey" {
  target_key_id = aws_kms_key.s3kmskey.key_id
  name          = "alias/${local.pipeline}"
}
