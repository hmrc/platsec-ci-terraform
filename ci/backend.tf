
terraform {
  required_version = ">=1.0.2"

  backend "s3" {
    bucket         = "platsec-ci20210713082841419000000002"
    region         = "eu-west-2"
    key            = "ci.tfstate"
    encrypt        = true
    kms_key_id     = "alias/s3-platsec-ci20210713082841419000000002"
    dynamodb_table = "platsec-ci"
  }
}
