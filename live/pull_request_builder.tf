module "platsec_terraform_pr_builder" {

  source = "../modules//pull_request_builder"

  codeconnection_arn    = data.aws_codestarconnections_connection.this.arn
  src_repo              = "platsec-terraform"
  buildspec             = "platsec_terraform_plan.yaml"
  docker_required       = true
  project_name          = "platsec-terraform-pr-builder"
  access_logs_bucket_id = data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string
  timeout_in_minutes    = 30

  admin_roles = local.tf_admin_roles
  project_assume_roles = {
    "SANDBOX_TERRAFORM_PLANNER_ROLE_ARN"     = local.accounts.sandbox.role_arns["terraform-planner"]
    "DEVELOPMENT_TERRAFORM_PLANNER_ROLE_ARN" = local.accounts.development.role_arns["terraform-planner"]
    "PRODUCTION_TERRAFORM_PLANNER_ROLE_ARN"  = local.accounts.production.role_arns["terraform-planner"]
  }

  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "platsec_terraform_pr_builder"
  }
}

module "central_audit_pr_builder" {

  source = "../modules//pull_request_builder"

  codeconnection_arn    = data.aws_codestarconnections_connection.this.arn
  src_repo              = "central-audit-terraform"
  buildspec             = "central_audit_terraform_plan.yaml"
  docker_required       = true
  project_name          = "central-audit-terraform-pr-builder"
  access_logs_bucket_id = data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string

  admin_roles = local.tf_admin_roles
  project_assume_roles = {
    "DEVELOPMENT_TERRAFORM_PLANNER_ROLE_ARN" = local.accounts.central_audit_development.role_arns["terraform-planner"]
    "PRODUCTION_TERRAFORM_PLANNER_ROLE_ARN"  = local.accounts.central_audit_production.role_arns["terraform-planner"]
  }

  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "central_audit_pr_builder"
  }
}

module "platsec_catalogue_pr_builder" {

  source = "../modules//pull_request_builder"

  codeconnection_arn    = data.aws_codestarconnections_connection.this.arn
  src_repo              = "platsec-catalogue"
  buildspec             = "platsec-catalogue.yaml"
  docker_required       = true
  project_name          = "platsec-catalogue-pr-builder"
  access_logs_bucket_id = data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string

  admin_roles          = local.tf_admin_roles
  project_assume_roles = {}

  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "platsec_catalogue_pr_build"
  }
}

module "monitor_aws_iam_pr_builder" {

  source = "../modules//pull_request_builder"

  codeconnection_arn    = data.aws_codestarconnections_connection.this.arn
  src_repo              = "monitor-aws-iam"
  buildspec             = "monitor-aws-iam.yaml"
  docker_required       = true
  project_name          = "monitor-aws-iam-pr-builder"
  access_logs_bucket_id = data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string

  admin_roles          = local.tf_admin_roles
  project_assume_roles = {}

  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "monitor_aws_iam_pr_builder"
  }
}

module "aws_scanner_pr_builder" {

  source = "../modules//pull_request_builder"

  codeconnection_arn    = data.aws_codestarconnections_connection.this.arn
  src_repo              = "platsec-aws-scanner"
  buildspec             = "aws-scanner.yaml"
  docker_required       = true
  project_name          = "aws-scanner-pr-builder"
  access_logs_bucket_id = data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string

  admin_roles          = local.tf_admin_roles
  project_assume_roles = {}

  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "aws-scanner"
  }
}

module "bitwarden_manager_pr_builder" {

  source = "../modules//pull_request_builder"

  codeconnection_arn    = data.aws_codestarconnections_connection.this.arn
  src_repo              = "bitwarden-manager"
  buildspec             = "bitwarden-manager.yaml"
  docker_required       = true
  project_name          = "bitwarden-manager-pr-builder"
  access_logs_bucket_id = data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string

  admin_roles          = local.tf_admin_roles
  project_assume_roles = {}

  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "bitwarden-manager"
  }
}

module "aws_users_manager_pr_builder" {

  source = "../modules//pull_request_builder"

  codeconnection_arn    = data.aws_codestarconnections_connection.this.arn
  src_repo              = "aws-users-manager"
  buildspec             = "aws-users-manager.yaml"
  docker_required       = true
  project_name          = "aws-users-manager-pr-builder"
  access_logs_bucket_id = data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string

  admin_roles          = local.tf_admin_roles
  project_assume_roles = {}

  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "aws_users_manager_pr_builder"
  }
}

module "prowler_scanner_pr_builder" {

  source = "../modules//pull_request_builder"

  codeconnection_arn    = data.aws_codestarconnections_connection.this.arn
  src_repo              = "prowler-scanner"
  buildspec             = "prowler-scanner.yaml"
  docker_required       = true
  project_name          = "prowler-scanner-pr-builder"
  access_logs_bucket_id = data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string

  admin_roles          = local.tf_admin_roles
  project_assume_roles = {}

  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "prowler_scanner_pr_builder"
  }
}

module "prowler_scan_enqueuer_pr_builder" {

  source = "../modules//pull_request_builder"

  codeconnection_arn    = data.aws_codestarconnections_connection.this.arn
  src_repo              = "prowler-scan-enqueuer"
  buildspec             = "prowler-scan-enqueuer.yaml"
  docker_required       = true
  project_name          = "prowler-scan-enqueuer-pr-builder"
  access_logs_bucket_id = data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string

  admin_roles          = local.tf_admin_roles
  project_assume_roles = {}

  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "prowler-scan-enqueuer-pr-builder"
  }
}

module "cloudtrail_monitoring_pr_builder" {

  source = "../modules//pull_request_builder"

  codeconnection_arn    = data.aws_codestarconnections_connection.this.arn
  src_repo              = "platsec-cloudtrail-monitoring"
  buildspec             = "cloudtrail-monitoring.yaml"
  docker_required       = true
  project_name          = "cloudtrail-monitoring-pr-builder"
  access_logs_bucket_id = data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string

  admin_roles          = local.tf_admin_roles
  project_assume_roles = {}

  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "cloudtrail-monitoring"
  }
}

module "compliance_alerting_pr_builder" {

  source = "../modules//pull_request_builder"

  codeconnection_arn    = data.aws_codestarconnections_connection.this.arn
  src_repo              = "platsec-compliance-alerting"
  buildspec             = "compliance-alerting.yaml"
  docker_required       = true
  project_name          = "compliance-alerting-pr-builder"
  access_logs_bucket_id = data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string

  admin_roles          = local.tf_admin_roles
  project_assume_roles = {}

  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "compliance-alerting"
  }
}
