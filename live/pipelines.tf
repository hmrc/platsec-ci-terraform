module "aws_scanner" {
  source = "../modules//lambda_docker_pipeline"

  pipeline_name = "aws-scanner"
  src_repo      = "platsec-aws-scanner"
  branch        = "main"

  lambda_function_name = "platsec_aws_scanner_lambda"
  ecr_arn              = module.aws_scanner_repository.arn
  ecr_url              = module.aws_scanner_repository.url

  accounts                 = local.accounts
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  github_token             = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "aws_scanner"
  }
}

module "compliance_alerting" {
  source = "../modules//lambda_docker_pipeline"

  pipeline_name = "compliance-alerting"
  src_repo      = "platsec-compliance-alerting"
  branch        = "main"


  lambda_function_name = "platsec_compliance_alerting_lambda"
  ecr_arn              = module.compliance_alerting_repository.arn
  ecr_url              = module.compliance_alerting_repository.url

  accounts                 = local.accounts
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  github_token             = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "compliance_alerting"
  }
}

module "bitwarden_manager" {
  source = "../modules//lambda_docker_pipeline"

  pipeline_name = "bitwarden-manager"
  src_repo      = "bitwarden-manager"

  lambda_function_name = "bitwarden_manager_lambda"
  ecr_url              = module.bitwarden_manager_repository.url
  ecr_arn              = module.bitwarden_manager_repository.arn

  accounts                 = local.accounts
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  github_token             = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "bitwarden_manager"
  }
}

module "cloudtrail_monitoring" {
  source = "../modules//lambda_docker_pipeline"

  pipeline_name = "cloudtrail-monitoring"
  src_repo      = "platsec-cloudtrail-monitoring"

  lambda_function_name = "platsec-cloudtrail-monitoring"
  ecr_url              = module.cloudtrail_monitoring_repository.url
  ecr_arn              = module.cloudtrail_monitoring_repository.arn

  accounts                 = local.accounts
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  github_token             = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "cloudtrail_monitoring"
  }
}

module "github_scanner" {
  source = "../modules//lambda_zip_pipeline"

  pipeline_name = "github-scanner"
  src_repo      = "platsec-scanning-tools"
  github_token  = data.aws_secretsmanager_secret_version.github_token.secret_string

  lambda_function_name = "github_scanner"

  accounts                 = local.accounts
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "github_scanner"
  }
}

module "github_admin_report" {
  source = "../modules//lambda_docker_pipeline"

  pipeline_name = "github-admin-report"
  src_repo      = "github-admin-report-lambda"
  branch        = "main"

  lambda_function_name = "github_admin_report_lambda"
  ecr_arn              = module.github_admin_report_repository.arn
  ecr_url              = module.github_admin_report_repository.url

  accounts                 = local.accounts
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  github_token             = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "github_admin_report"
  }
}

module "github_webhook_report" {
  source = "../modules//lambda_docker_pipeline"

  pipeline_name = "github-webhook-report"
  src_repo      = "github-webhook-report-lambda"
  branch        = "main"

  lambda_function_name = "github_webhook_report_lambda"
  ecr_arn              = module.github_webhook_report_repository.arn
  ecr_url              = module.github_webhook_report_repository.url

  accounts                 = local.accounts
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  github_token             = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "github_webhook_report"
  }
}

module "monitor_aws_iam" {
  source = "../modules//lambda_docker_pipeline"

  pipeline_name = "monitor-aws-iam"
  src_repo      = "monitor-aws-iam"
  branch        = "main"

  lambda_function_name = "monitor_aws_iam_lambda"
  ecr_arn              = module.monitor_aws_iam_repository.arn
  ecr_url              = module.monitor_aws_iam_repository.url

  accounts                 = local.accounts
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  github_token             = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "monitor_aws_iam"
  }
}

module "vault_policy_applier_corretto" {
  source = "../modules//lambda_zip_pipeline"

  pipeline_name = "vault-policy-applier-corretto"
  src_repo      = "vault-policy-applier"
  github_token  = data.aws_secretsmanager_secret_version.github_token.secret_string

  lambda_function_name           = "policy-applier-corretto"
  lambda_deployment_package_name = "vault-policy-applier-2-SNAPSHOT.jar"

  accounts                 = local.accounts
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "vault_policy_applier_corretto"
  }
}

module "renovatebot" {
  source = "../modules//renovatebot_build"

  accounts                 = local.accounts
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids
  enable_break_points      = false

  repositories = [
    "hmrc/vault-policy-generator"
  ]

  tags = {
    service = "renovatebot"
  }
}

module "security_reports_frontend" {
  source = "../modules//ecs_task_pipeline"

  pipeline_name = "compliance-dataviz"
  src_repo      = "platsec-compliance-dataviz"
  branch        = "main"

  cluster_name = "security_reports_frontend"
  service_name = "compliance_dataviz"
  task_name    = "compliance_dataviz_task"
  ecr_url      = module.security_reports_frontend_repository.url
  ecr_arn      = module.security_reports_frontend_repository.arn

  accounts                 = local.accounts
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  github_token             = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "security_reports_frontend"
  }
}

module "sandbox_aws_nuke" {
  source = "../modules//sandbox_lambda_docker_pipeline"

  pipeline_name = "sandbox-aws-nuke"
  src_repo      = "platsec-aws-nuke-lambda"
  branch        = "main"

  lambda_function_name = "go-nuke"
  ecr_arn              = module.go_nuke_repository.arn
  ecr_url              = module.go_nuke_repository.url

  accounts                 = local.accounts
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  github_token             = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "sandbox_aws_nuke"
  }
}

module "sandbox_compliance_alerting" {
  source = "../modules//sandbox_lambda_docker_pipeline"

  pipeline_name = "sandbox-compliance-alerting"
  src_repo      = "platsec-compliance-alerting"
  branch        = "sandbox"

  lambda_function_name = "platsec_compliance_alerting_lambda"
  ecr_arn              = module.compliance_alerting_repository.arn
  ecr_url              = module.compliance_alerting_repository.url

  accounts                 = local.accounts
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  github_token             = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "sandbox_compliance_alerting"
  }
}

module "tf-s3-bucket-core" {
  source = "../modules//terraform_module_pipeline"

  pipeline_name = "terraform-aws-s3-bucket-core"
  src_repo      = "terraform-aws-s3-bucket-core"
  branch        = "main"

  accounts                 = local.accounts
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  github_token             = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "tf-s3-bucket-core"
  }
}

module "tf-s3-bucket-standard" {
  source = "../modules//terraform_module_pipeline"

  pipeline_name = "terraform-aws-s3-bucket-standard"
  src_repo      = "terraform-aws-s3-bucket-standard"
  branch        = "main"

  test_timeout_in_minutes = 25

  accounts                 = local.accounts
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  github_token             = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "tf-s3-bucket-standard"
  }
}

module "platsec-terraform-pipeline" {

  source = "../modules//platsec_terraform_pipeline"

  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  github_token             = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  step_assume_roles = [
    {
      sandbox = {
        "TERRAFORM_APPLIER_ROLE_ARN" = local.accounts.sandbox.role_arns["terraform-applier"]
      }
    },
    {
      development = {
        "TERRAFORM_APPLIER_ROLE_ARN" = local.accounts.development.role_arns["terraform-applier"]
      }
    },
    {
      production = {
        "TERRAFORM_APPLIER_ROLE_ARN" = local.accounts.production.role_arns["terraform-applier"]
      }
    },
  ]

  tags = {
    service = "platsec-terraform-pipeline"
  }
}

moved {
  from = module.central_account_pipeline
  to   = module.central_account_terraform_pipeline
}

module "central_account_terraform_pipeline" {
  source = "../modules//central_audit_terraform_pipeline"

  src_repo = "central-audit-terraform"
  branch   = "main"

  access_log_bucket_id     = local.access_log_bucket_id
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  github_token             = data.aws_secretsmanager_secret_version.github_token.secret_string
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  step_assume_roles = [
    {
      development = {
        "DEVELOPMENT_TERRAFORM_APPLIER_ROLE_ARN" = local.accounts.central_audit_development.role_arns["terraform-applier"]
      }
    },
    {
      production = {
        "PRODUCTION_TERRAFORM_APPLIER_ROLE_ARN" = local.accounts.central_audit_production.role_arns["terraform-applier"]
      }
    },
  ]

  tags = {
    service = "central_account_terraform_pipeline"
  }
}

module "aws_users_manager" {
  source = "../modules//lambda_docker_pipeline"

  pipeline_name = "aws-users-manager"
  src_repo      = "aws-users-manager"

  lambda_function_name = "aws-users-manager-lambda"
  ecr_url              = module.aws_users_manager_repository.url
  ecr_arn              = module.aws_users_manager_repository.arn

  accounts                 = local.accounts
  codeconnection_arn       = data.aws_codestarconnections_connection.this.arn
  github_token             = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn            = local.ci_alerts_sns_topic_arn
  access_log_bucket_id     = local.access_log_bucket_id
  admin_roles              = local.tf_admin_roles
  vpc_config               = local.vpc_config
  agent_security_group_ids = local.agent_security_group_ids

  tags = {
    service = "aws_users_manager"
  }
}

module "prowler_scanner" {
  source = "../modules//lambda_docker_pipeline"

  pipeline_name = "prowler-scanner"
  src_repo      = "prowler-scanner"

  lambda_function_name = "prowler-scanner-lambda"
  ecr_url              = module.prowler_scanner_repository.url
  ecr_arn              = module.prowler_scanner_repository.arn

  accounts                        = local.accounts
  codeconnection_arn              = data.aws_codestarconnections_connection.this.arn
  github_token                    = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn                   = local.ci_alerts_sns_topic_arn
  access_log_bucket_id            = local.access_log_bucket_id
  admin_roles                     = local.tf_admin_roles
  vpc_config                      = local.vpc_config
  agent_security_group_ids        = local.agent_security_group_ids
  build_timeout_in_minutes        = 15
  upload_image_timeout_in_minutes = 10

  tags = {
    service = "prowler-scanner"
  }
}

module "prowler_scan_enqueuer" {
  source = "../modules//lambda_docker_pipeline"

  pipeline_name = "prowler-scan-enqueuer"
  src_repo      = "prowler-scan-enqueuer"

  lambda_function_name = "prowler-scan-enqueuer-lambda"
  ecr_url              = module.prowler_scan_enqueuer_repository.url
  ecr_arn              = module.prowler_scan_enqueuer_repository.arn

  accounts                        = local.accounts
  codeconnection_arn              = data.aws_codestarconnections_connection.this.arn
  github_token                    = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn                   = local.ci_alerts_sns_topic_arn
  access_log_bucket_id            = local.access_log_bucket_id
  admin_roles                     = local.tf_admin_roles
  vpc_config                      = local.vpc_config
  agent_security_group_ids        = local.agent_security_group_ids
  build_timeout_in_minutes        = 15
  upload_image_timeout_in_minutes = 10

  tags = {
    service = "prowler-scan-enqueuer"
  }
}

