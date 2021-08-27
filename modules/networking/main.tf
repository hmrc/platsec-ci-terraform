locals {
  live_artifactory_endpoint_name = "com.amazonaws.vpce.eu-west-2.vpce-svc-06f82f7a1b56d9744"
}

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.no-default-tags]
    }
  }
}

