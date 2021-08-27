data "aws_region" "current" {}

module "artifactory_endpoint_connector" {
  source = "git@github.com:hmrc/mdtp-build.git//terraform/modules/service_endpoint_connector?ref=v0.12"

  security_group_name = "${var.name_prefix}-artifactory-endpoint"
  vpc_id              = module.vpc.vpc_id
  service_name        = local.live_artifactory_endpoint_name
  subnet_ids          = module.vpc.private_subnets

  subdomains = [
    "artefacts",
    "dockerhub",
    "pythonpips",
  ]
  top_level_domain = "tax.service.gov.uk"
}

# CloudWatch Logs to be able to see agent logs in CodeBuild
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.aws_interface_endpoints.id,
  ]

  subnet_ids = module.vpc.private_subnets

  private_dns_enabled = true

  tags = {
    Name : "${var.name_prefix}-logs"
  }
}

# ECR for ECR Native API
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.aws_interface_endpoints.id,
  ]

  subnet_ids = module.vpc.private_subnets

  private_dns_enabled = true

  tags = {
    Name : "${var.name_prefix}-ecr-api"
  }
}

# ECR for Docker Registry API
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.aws_interface_endpoints.id,
  ]

  subnet_ids = module.vpc.private_subnets

  private_dns_enabled = true

  tags = {
    Name : "${var.name_prefix}-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "lambda" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.lambda"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.aws_interface_endpoints.id,
  ]

  subnet_ids = module.vpc.private_subnets

  private_dns_enabled = true

  tags = {
    Name : "${var.name_prefix}-lambda"
  }
}

# S3 for downloading source code
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  tags = {
    Name : "${var.name_prefix}-s3"
  }
}

resource "aws_vpc_endpoint" "sts" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.sts"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.aws_interface_endpoints.id,
  ]

  subnet_ids = module.vpc.private_subnets

  private_dns_enabled = true

  tags = {
    Name : "${var.name_prefix}-sts"
  }
}

