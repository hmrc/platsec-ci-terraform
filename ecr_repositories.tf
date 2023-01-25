module "bitwarden-manager-repository" {
  source = "./modules/ecr_repository"

  repository_name            = "bitwarden-manager"
  allow_read_account_id_list = local.all_account_ids
}

module "aws-scanner-repository" {
  source = "./modules/ecr_repository"

  repository_name            = "aws-scanner"
  allow_read_account_id_list = local.all_account_ids
}

module "compliance-alerting-repository" {
  source = "./modules/ecr_repository"

  repository_name            = "compliance-alerting"
  allow_read_account_id_list = local.all_account_ids
}

module "github-admin-report-repository" {
  source = "./modules/ecr_repository"

  repository_name            = "github-admin-report"
  allow_read_account_id_list = local.all_account_ids
}

module "github-webhook-report-repository" {
  source = "./modules/ecr_repository"

  repository_name            = "github-webhook-report"
  allow_read_account_id_list = local.all_account_ids
}
