terraform {
  required_version = ">=1.0.2"

  backend "s3" {
    key    = "bootstrap/v1"
    bucket = "\n-------------------------\nPlease read the README.md first 📖\n------------------------"
    region = "\n-------------------------\nPlease read the README.md first 📖\n------------------------"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.49"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

locals {
  backend_content = <<-EOT
    bucket = "${aws_s3_bucket.s3_bucket.bucket}"
    region = "eu-west-2"
    dynamodb_table = "${aws_dynamodb_table.terraform_state_lock.name}"
  EOT
}

resource "aws_secretsmanager_secret" "backend" {
  name       = "backend.hcl"
  kms_key_id = aws_kms_key.terraform_key.key_id
}

resource "aws_secretsmanager_secret_version" "backend" {
  secret_id     = aws_secretsmanager_secret.backend.id
  secret_string = local.backend_content
}

resource "local_file" "backend" {
  filename = "../backend.hcl"
  content  = local.backend_content
}
