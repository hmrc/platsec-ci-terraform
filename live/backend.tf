terraform {
  backend "s3" {
    bucket         = "platsec-ci20210713082841419000000002"
    region         = "eu-west-2"
    key            = "platsec-ci/v1"
    dynamodb_table = "platsec-ci"
  }
}
