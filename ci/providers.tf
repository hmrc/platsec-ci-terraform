provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      "team:product" : "platsec:${local.repo}"
      "Git_Project" : "${local.repo}"
    }
  }
}

# https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/625
provider "aws" {
  alias  = "no-default-tags"
  region = "eu-west-2"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}