resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.name_prefix}-artifact-store"
  acl    = "private"

  force_destroy = true
}

resource "aws_kms_key" "s3kmskey" {}

resource "aws_kms_alias" "s3kmskey" {
  target_key_id = aws_kms_key.s3kmskey.key_id
  name          = "alias/${var.name_prefix}-s3kmskey"
}
