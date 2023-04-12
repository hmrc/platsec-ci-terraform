module "vpc" {
  providers = {
    # https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/625
    aws = aws.no-default-tags
  }

  source = "git@github.com:hmrc/terraform-aws-vpc.git?ref=v3.6.0"

  name = var.name_prefix

  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
}
