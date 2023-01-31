terraform {
  backend "s3" {
    bucket         = "platsec-tf-state-development-759b74ce43947f5f4c91aeddc3e5bad3"
    region         = "eu-west-2"
    key            = "components/pull_request_builder.tfstate"
    dynamodb_table = "platsec-tf-lock-development-759b74ce43947f5f4c91aeddc3e5bad3"
  }
}
