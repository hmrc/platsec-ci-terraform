module "platsec_terraform_pr_builder" {

  source = "../modules//pull_request_builder"

  src_repo              = "platsec-terraform"
  buildspec             = "platsec_terraform_plan.yaml"
  docker_required       = true
  project_name          = "platsec-terraform-pr-builder"
  access_logs_bucket_id = data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string

  admin_role = local.tf_admin_role
  project_assume_roles = {
    "SANDBOX_TERRAFORM_PLANNER_ROLE_ARN"     = local.accounts.sandbox.role_arns["terraform-planner"]
    "DEVELOPMENT_TERRAFORM_PLANNER_ROLE_ARN" = local.accounts.development.role_arns["terraform-planner"]
    "PRODUCTION_TERRAFORM_PLANNER_ROLE_ARN"  = local.accounts.production.role_arns["terraform-planner"]
  }

  vpc_config = local.vpc_config
  agent_security_group_ids = [
    local.ci_agent_to_internet_sg_id,
    local.ci_agent_to_endpoints_sg_id
  ]
}

module "central_audit_pr_builder" {

  source = "../modules//pull_request_builder"

  src_repo              = "central-audit-terraform"
  buildspec             = "central_audit_terraform_plan.yaml"
  docker_required       = true
  project_name          = "central-audit-terraform-pr-builder"
  access_logs_bucket_id = data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string

  admin_role = local.tf_admin_role
  project_assume_roles = {
    "DEVELOPMENT_TERRAFORM_PLANNER_ROLE_ARN" = local.accounts.central_audit_development.role_arns["terraform-planner"]
    "PRODUCTION_TERRAFORM_PLANNER_ROLE_ARN"  = local.accounts.central_audit_production.role_arns["terraform-planner"]
  }

  vpc_config = local.vpc_config
  agent_security_group_ids = [
    local.ci_agent_to_internet_sg_id,
    local.ci_agent_to_endpoints_sg_id
  ]
}

module "platsec_catalogue_pr_builder" {

  source = "../modules//pull_request_builder"

  src_repo              = "platsec-catalogue"
  buildspec             = "platsec-catalogue.yaml"
  docker_required       = true
  project_name          = "platsec-catalogue-pr-builder"
  access_logs_bucket_id = data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string

  admin_role           = local.tf_admin_role
  project_assume_roles = {}

  vpc_config = local.vpc_config
  agent_security_group_ids = [
    local.ci_agent_to_internet_sg_id,
    local.ci_agent_to_endpoints_sg_id
  ]
}

module "monitor_aws_iam_pr_builder" {

  source = "../modules//pull_request_builder"

  src_repo              = "monitor-aws-iam"
  buildspec             = "monitor-aws-iam.yaml"
  docker_required       = true
  project_name          = "monitor-aws-iam-pr-builder"
  access_logs_bucket_id = data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string

  admin_role           = local.tf_admin_role
  project_assume_roles = {}

  vpc_config = local.vpc_config
  agent_security_group_ids = [
    local.ci_agent_to_internet_sg_id,
    local.ci_agent_to_endpoints_sg_id
  ]
}
