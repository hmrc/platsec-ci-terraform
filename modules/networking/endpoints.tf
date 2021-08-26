resource "aws_security_group" "endpoints" {
  vpc_id = module.vpc.vpc_id

  name = "${var.name_prefix}-endpoints"

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  tags = {
    Name : "${var.name_prefix}-s3"
  }
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.endpoints.id,
  ]

  subnet_ids = module.vpc.private_subnets

  private_dns_enabled = true

  tags = {
    Name : "${var.name_prefix}-logs"
  }
}

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
