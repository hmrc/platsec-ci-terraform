output "source_v2_github_connection_arn" {
  value = aws_codestarconnections_connection.github.arn
}

output "source_v1_oauth_token" {
  value = data.aws_secretsmanager_secret_version.github_token.secret_string
}
