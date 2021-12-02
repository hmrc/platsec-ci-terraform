output "bucket_id" {
  value = aws_s3_bucket.codepipeline_bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.codepipeline_bucket.arn
}

output "kms_key_arn" {
  value = aws_kms_key.s3kmskey.arn
}
