module "platsec_terraform_pr_jobs" {
  source = "../modules//terraform_pr_builder"

  codeconnection_arn = data.aws_codestarconnections_connection.this.arn
  src_repo           = "platsec-terraform"

  accounts                 = local.account_list["platsec"]
  assumable_roles          = [for environment in ["development", "production"] : local.account_list["platsec"][environment].role_arns["terraform-planner"]]
  environments             = ["development", "production"]
  environment_compute_type = "BUILD_GENERAL1_LARGE"

  vpc_config_security_group_ids = [local.agent_security_group_ids.internet, local.agent_security_group_ids.service_endpoints]
  vpc_config_subnets            = local.vpc_config.private_subnet_ids
  vpc_config_vpc_id             = local.vpc_config.vpc_id

  tags = {
    service = "platsec_terraform_pr_builder"
  }
}

module "central_audit_pr_jobs" {
  source = "../modules//terraform_pr_builder"

  codeconnection_arn = data.aws_codestarconnections_connection.this.arn
  src_repo           = "central-audit-terraform"

  accounts                 = local.account_list["central-audit"]
  assumable_roles          = [for environment in ["development", "production"] : local.account_list["central-audit"][environment].role_arns["terraform-planner"]]
  environments             = ["development", "production"]
  environment_compute_type = "BUILD_GENERAL1_LARGE"

  vpc_config_security_group_ids = [local.agent_security_group_ids.internet, local.agent_security_group_ids.service_endpoints]
  vpc_config_subnets            = local.vpc_config.private_subnet_ids
  vpc_config_vpc_id             = local.vpc_config.vpc_id

  tags = {
    service = "central_audit_pr_builder"
  }
}

module "aws_grant_user_access_pr_jobs" {
  source = "../modules//terraform_pr_builder"

  codeconnection_arn = data.aws_codestarconnections_connection.this.arn
  src_repo           = "aws-grant-user-access"

  # aws-grant-user-access doesn't have dedicated development environment so we are using platsec-development for testing
  accounts                 = { development = local.accounts.development, production = local.accounts.auth }
  assumable_roles          = [local.accounts.development.role_arns["terraform-planner"], local.accounts.auth.role_arns["terraform-planner"]]
  environments             = ["development", "production"]
  environment_compute_type = "BUILD_GENERAL1_LARGE"

  vpc_config_security_group_ids = [local.agent_security_group_ids.internet, local.agent_security_group_ids.service_endpoints]
  vpc_config_subnets            = local.vpc_config.private_subnet_ids
  vpc_config_vpc_id             = local.vpc_config.vpc_id

  tags = {
    service = "aws_grant_user_access_pr_builder"
  }
}
