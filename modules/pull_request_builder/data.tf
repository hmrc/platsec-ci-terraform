data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_codestarconnections_connection" "this" {
  name = "platsec-ci"
}