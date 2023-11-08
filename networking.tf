locals {
  live_vpc_name = "mdtp-live-platsec-ci"

  vpc_config = local.is_live ? module.networking[0].vpc_config : {
    vpc_id              = data.aws_vpc.live[0].id,
    private_subnet_ids  = data.aws_subnets.private[0].ids,
    private_subnet_arns = [for subnet in data.aws_subnet.live : subnet.arn],
  }
  ci_agent_to_internet_sg_id  = local.is_live ? module.networking[0].ci_agent_to_internet_sg_id : data.aws_security_group.ci_agent_to_internet[0].id
  ci_agent_to_endpoints_sg_id = local.is_live ? module.networking[0].ci_agent_to_endpoints_sg_id : data.aws_security_group.ci_agent_to_endpoints[0].id
}

module "networking" {
  count = local.is_live ? 1 : 0
  providers = {
    aws.no-default-tags = aws.no-default-tags
  }

  name_prefix = module.label.id
  source      = "./modules/networking"
}

data "aws_security_group" "ci_agent_to_internet" {
  count = local.is_live ? 0 : 1
  name  = "${local.live_vpc_name}-agent-to-internet*"
}

data "aws_security_group" "ci_agent_to_endpoints" {
  count = local.is_live ? 0 : 1
  name  = "${local.live_vpc_name}-agent-to-endpoints*"
}

data "aws_vpc" "live" {
  count = local.is_live ? 0 : 1
  filter {
    name   = "tag:Name"
    values = [local.live_vpc_name]
  }
}

data "aws_subnets" "private" {
  count = local.is_live ? 0 : 1
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.live[0].id]
  }

  filter {
    name   = "tag:Name"
    values = ["*-private-*"]
  }
}

data "aws_subnet" "live" {
  for_each = local.is_live ? toset([]) : toset(data.aws_subnets.private[0].ids)
  id       = each.value
}
