resource "aws_codestarconnections_connection" "connection" {
  name          = var.name
  provider_type = "GitHub"
  tags          = var.tags
}