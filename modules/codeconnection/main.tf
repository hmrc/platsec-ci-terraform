resource "aws_codestarconnections_connection" "connection" {
  name = var.name

  #restrict access to this as we're only expecting GitHub
  provider_type = "GitHub"

  tags = var.tags
}