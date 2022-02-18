locals {
  bucket_name = "ci-${substr(local.pipeline_name, 0, 32)}"

}


data "aws_iam_policy_document" "kms" {
  statement {
    sid = "Allow-IAM"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      type        = "AWS"
    }

  }

}


module "codepipeline_bucket" {
  source        = "hmrc/s3-bucket-core/aws"
  version       = "0.1.1"
  bucket_name   = local.bucket_name                     # bucket_prefix
  force_destroy = true
  kms_key_policy = null

  data_expiry      = "90-days"
  data_sensitivity = "low"

  log_bucket_id = var.access_log_bucket_id
  tags          =  {
    Pipeline = local.pipeline_name
  }
}




#resource "aws_s3_bucket" "codepipeline_bucket" {
#  bucket_prefix = "ci-${substr(local.pipeline_name, 0, 32)}"
#  acl           = "private"

#  force_destroy = true

#  server_side_encryption_configuration {
#    rule {
#      apply_server_side_encryption_by_default {
#        kms_master_key_id = aws_kms_key.codepipeline_bucket.arn
#        sse_algorithm     = "aws:kms"
#      }
#    }
#  }

#  versioning {
#    enabled = true
#  }

#  lifecycle_rule {
#    enabled = false
#    expiration {
#      days = 90
#    }
#    noncurrent_version_expiration {
#      days = 90
#    }
#  }

#  tags = {
#    Pipeline = local.pipeline_name
#  }
#}

#resource "aws_s3_bucket_public_access_block" "codepipeline_bucket" {
#  bucket                  = aws_s3_bucket.codepipeline_bucket.bucket
#  block_public_acls       = true
#  block_public_policy     = true
#  ignore_public_acls      = true
#  restrict_public_buckets = true
#}
#
#resource "aws_kms_key" "codepipeline_bucket" {}
#
#resource "aws_kms_alias" "codepipeline_bucket" {
#  target_key_id = aws_kms_key.codepipeline_bucket.key_id
#  name          = "alias/ci-${local.pipeline_name}"
#}
