terraform {
  required_version = ">=1.0.2"
}

provider "aws" {
  region = "eu-west-2"
}

variable "boostrap_name" {
  description = "name that resources will be given (usually the name of the aws account)"
  type        = string
  default     = "platsec-ci"
}