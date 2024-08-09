output "bucket_id" {
  value = module.codepipeline_bucket.id
}

output "bucket_arn" {
  value = module.codepipeline_bucket.arn
}

output "kms_key_arn" {
  value = module.codepipeline_bucket.kms_key_arn
}

output "artifactory_secret_manager_names" {
  value = local.artifactory_secret_manager_names
}

output "codepipeline_role_arn" {
  value = aws_iam_role.codepipeline_role.arn
}

output "policy_build_core_arn" {
  value = aws_iam_policy.build_core.arn
}

output "policy_get_artifactory_credentials_arn" {
  value = aws_iam_policy.get_artifactory_credentials.arn
}

output "pipeline_name" {
  value = local.pipeline_name
}

output "build_id" {
  value = "#{SourceVariables.CommitId}-#{Timestamp.BUILD_TIMESTAMP}"
}
