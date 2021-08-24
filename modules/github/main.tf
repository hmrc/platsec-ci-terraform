terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# you need to activate this resource here https://console.aws.amazon.com/codesuite/settings/connections
resource "aws_codestarconnections_connection" "github" {
  name          = var.name_prefix
  provider_type = "GitHub"
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = "/service_accounts/github_api_token"
}
