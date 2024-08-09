module "bitwarden_manager_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "bitwarden-manager"
  allow_read_account_id_list = local.all_platsec_account_ids
}

module "aws_scanner_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "aws-scanner"
  allow_read_account_id_list = local.all_platsec_account_ids
}

module "cloudtrail_monitoring_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "cloudtrail-monitoring"
  allow_read_account_id_list = local.all_platsec_account_ids
}


module "compliance_alerting_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "compliance-alerting"
  allow_read_account_id_list = local.all_platsec_account_ids
}

module "github_admin_report_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "github-admin-report"
  allow_read_account_id_list = local.all_platsec_account_ids
}

module "github_webhook_report_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "github-webhook-report"
  allow_read_account_id_list = local.all_platsec_account_ids
}

module "monitor_aws_iam_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "monitor-aws-iam"
  allow_read_account_id_list = local.all_platsec_account_ids
}

module "go_nuke_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "go-nuke"
  allow_read_account_id_list = [local.accounts.sandbox.id]
}

module "security_reports_frontend_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "security-reports-frontend"
  allow_read_account_id_list = local.all_platsec_account_ids
}
