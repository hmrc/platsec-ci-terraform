module "bitwarden_manager_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "bitwarden-manager"
  allow_read_account_id_list = local.all_platsec_account_ids

  tags = {
    service = "bitwarden_manager"
  }
}

module "aws_users_manager_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "aws-users-manager"
  allow_read_account_id_list = local.all_platsec_account_ids

  tags = {
    service = "aws-users-manager"
  }
}

module "prowler_scanner_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "prowler-scanner"
  allow_read_account_id_list = local.all_platsec_account_ids

  tags = {
    service = "prowler-scanner"
  }
}

module "prowler_scan_enqueuer_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "prowler-scan-enqueuer"
  allow_read_account_id_list = local.all_platsec_account_ids

  tags = {
    service = "prowler-scan-enqueuer"
  }
}

module "aws_scanner_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "aws-scanner"
  allow_read_account_id_list = local.all_platsec_account_ids

  tags = {
    service = "aws_scanner"
  }
}

module "cloudtrail_monitoring_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "cloudtrail-monitoring"
  allow_read_account_id_list = local.all_platsec_account_ids

  tags = {
    service = "cloudtrail_monitoring"
  }
}


module "compliance_alerting_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "compliance-alerting"
  allow_read_account_id_list = local.all_platsec_account_ids

  tags = {
    service = "compliance_alerting"
  }
}

module "github_admin_report_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "github-admin-report"
  allow_read_account_id_list = local.all_platsec_account_ids

  tags = {
    service = "github_admin_report"
  }
}

module "github_webhook_report_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "github-webhook-report"
  allow_read_account_id_list = local.all_platsec_account_ids

  tags = {
    service = "github_webhook_report"
  }
}

module "monitor_aws_iam_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "monitor-aws-iam"
  allow_read_account_id_list = local.all_platsec_account_ids

  tags = {
    service = "monitor_aws_iam"
  }
}

module "go_nuke_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "go-nuke"
  allow_read_account_id_list = [local.accounts.sandbox.id]

  tags = {
    service = "go_nuke"
  }
}

module "security_reports_frontend_repository" {
  source = "../modules//ecr_repository"

  repository_name            = "security-reports-frontend"
  allow_read_account_id_list = local.all_platsec_account_ids

  tags = {
    service = "security_reports_frontend"
  }
}
