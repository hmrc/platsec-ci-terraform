# you need to activate this resource here https://console.aws.amazon.com/codesuite/settings/connections
resource "aws_codestarconnections_connection" "github" {
  name          = var.name_prefix
  provider_type = "GitHub"
}
