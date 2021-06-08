output "github_connection_arn" {
  value = aws_codestarconnections_connection.github.arn
}

output "kms_key_arn" {
  value = aws_kms_key.s3kmskey.arn
}

output "s3_bucket" {
  value = aws_s3_bucket.codepipeline_bucket
}
