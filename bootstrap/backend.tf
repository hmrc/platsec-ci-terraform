
terraform {
  required_version = ">=1.0.2"

  backend "s3" {
    bucket         = "platsec-ci20210713082841419000000002"
    region         = "eu-west-2"
    key            = "bootstrap/v1"
    encrypt        = true
    kms_key_id     = "alias/platsec-ci20210713082841419000000002"
    dynamodb_table = "platsec-ci"
  }

  # TODO: PSEC-2203 to revisit the config below
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
  }
}
