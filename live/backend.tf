terraform {
  backend "s3" {
    bucket       = "platsec-ci20210713082841419000000002"
    region       = "eu-west-2"
    key          = "platsec-ci/v1"
    use_lockfile = true
    encrypt      = true
    kms_key_id   = "alias/s3-platsec-ci20210713082841419000000002"
  }
}
