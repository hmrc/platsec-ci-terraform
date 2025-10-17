module "platsec_terraform_pr_jobs" {
  source = "../modules//terraform_pr_builder"

  codeconnection_arn = data.aws_codestarconnections_connection.this.arn
  src_repo           = "platsec-terraform"

  accounts        = local.accounts
  assumable_roles = [for environment in ["development", "production"] : local.accounts[environment].role_arns["terraform-planner"]]
  environments    = ["development", "production"]

  vpc_config_security_group_ids = [local.agent_security_group_ids.internet, local.agent_security_group_ids.service_endpoints]
  vpc_config_subnets            = local.vpc_config.private_subnet_ids
  vpc_config_vpc_id             = local.vpc_config.vpc_id

  tags = {
    service = "platsec_terraform_pr_builder"
  }
}