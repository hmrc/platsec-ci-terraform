locals {
  terraform_applier_role  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformApplier"
  terraform_planner_role  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformPlanner"
  access_logs_bucket_name = "platsec-ci-access-logs20220222104748703700000001"
}

module "pull_request_builder" {
  source = "../modules//pull_request_builder"

  project_name = "${local.repo}-pr-builder"
  project_assume_roles = {
    "TERRAFORM_PLANNER_ROLE_ARN" = local.terraform_planner_role
  }
  admin_role      = local.terraform_applier_role
  docker_required = true

  src_repo   = local.repo
  src_branch = ""
  buildspec  = "platsec_ci_terraform_plan.yaml"

  vpc_config = module.networking.vpc_config
  agent_security_group_ids = [
    module.networking.ci_agent_to_endpoints_sg_id,
    module.networking.ci_agent_to_internet_sg_id
  ]
  access_logs_bucket_id = local.access_logs_bucket_name
  timeout_in_minutes    = 30
}