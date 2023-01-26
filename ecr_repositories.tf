module "bitwarden_manager_repository" {
  source = "./modules/ecr_repository"

  repository_name            = "bitwarden-manager"
  allow_read_account_id_list = local.all_account_ids
}

module "aws_scanner_repository" {
  source = "./modules/ecr_repository"

  repository_name            = "aws-scanner"
  allow_read_account_id_list = local.all_account_ids
}

module "compliance_alerting_repository" {
  source = "./modules/ecr_repository"

  repository_name            = "compliance-alerting"
  allow_read_account_id_list = local.all_account_ids
}

module "github_admin_report_repository" {
  source = "./modules/ecr_repository"

  repository_name            = "github-admin-report"
  allow_read_account_id_list = local.all_account_ids
}

module "github_webhook_report_repository" {
  source = "./modules/ecr_repository"

  repository_name            = "github-webhook-report"
  allow_read_account_id_list = local.all_account_ids
}

module "go_nuke_repository" {
  source = "./modules/ecr_repository"

  repository_name            = "go-nuke-repository"
  allow_read_account_id_list = [local.accounts.sandbox.id]
}
