module "aws_scanner" {
  source = "./modules/lambda_docker_pipeline"

  pipeline_name = "aws-scanner"
  src_repo      = "platsec-aws-scanner"
  branch        = "main"

  lambda_function_name = "platsec_aws_scanner_lambda"
  ecr_arn              = module.aws_scanner_repository.arn
  ecr_url              = module.aws_scanner_repository.url

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
  access_log_bucket_id        = local.access_log_bucket_id
  admin_role                  = local.tf_admin_role
}

module "compliance_alerting" {
  source = "./modules/lambda_docker_pipeline"

  pipeline_name = "compliance-alerting"
  src_repo      = "platsec-compliance-alerting"
  branch        = "main"


  lambda_function_name = "platsec_compliance_alerting_lambda"
  ecr_arn              = module.compliance_alerting_repository.arn
  ecr_url              = module.compliance_alerting_repository.url

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
  access_log_bucket_id        = local.access_log_bucket_id
  admin_role                  = local.tf_admin_role
}

module "bitwarden_manager" {
  source = "./modules/lambda_docker_pipeline"

  pipeline_name = "bitwarden-manager"
  src_repo      = "bitwarden-manager"

  lambda_function_name = "bitwarden_manager_lambda"
  ecr_url              = module.bitwarden_manager_repository.url
  ecr_arn              = module.bitwarden_manager_repository.arn

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
  access_log_bucket_id        = local.access_log_bucket_id
  admin_role                  = local.tf_admin_role
}

module "cloudtrail_monitoring" {
  source = "./modules/lambda_docker_pipeline"

  pipeline_name = "cloudtrail-monitoring"
  src_repo      = "platsec-cloudtrail-monitoring"

  lambda_function_name = "orgtrail-monitoring"
  ecr_url              = module.cloudtrail_monitoring_repository.url
  ecr_arn              = module.cloudtrail_monitoring_repository.arn

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
  access_log_bucket_id        = local.access_log_bucket_id
  admin_role                  = local.tf_admin_role
}

module "github_scanner" {
  source = "./modules/lambda_zip_pipeline"

  pipeline_name = "github-scanner"
  src_repo      = "platsec-scanning-tools"
  github_token  = data.aws_secretsmanager_secret_version.github_token.secret_string

  lambda_function_name = "github_scanner"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
  access_log_bucket_id        = local.access_log_bucket_id
  admin_role                  = local.tf_admin_role
}

module "github_admin_report" {
  source = "./modules/lambda_docker_pipeline"

  pipeline_name = "github-admin-report"
  src_repo      = "github-admin-report-lambda"
  branch        = "main"

  lambda_function_name = "github_admin_report_lambda"
  ecr_arn              = module.github_admin_report_repository.arn
  ecr_url              = module.github_admin_report_repository.url

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
  access_log_bucket_id        = local.access_log_bucket_id
  admin_role                  = local.tf_admin_role
}

module "github_webhook_report" {
  source = "./modules/lambda_docker_pipeline"

  pipeline_name = "github-webhook-report"
  src_repo      = "github-webhook-report-lambda"
  branch        = "main"

  lambda_function_name = "github_webhook_report_lambda"
  ecr_arn              = module.github_webhook_report_repository.arn
  ecr_url              = module.github_webhook_report_repository.url

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
  access_log_bucket_id        = local.access_log_bucket_id
  admin_role                  = local.tf_admin_role
}

module "monitor_aws_iam" {
  source = "./modules/lambda_docker_pipeline"

  pipeline_name = "monitor-aws-iam"
  src_repo      = "monitor-aws-iam"
  branch        = "main"

  lambda_function_name = "monitor_aws_iam_lambda"
  ecr_arn              = module.monitor_aws_iam_repository.arn
  ecr_url              = module.monitor_aws_iam_repository.url

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
  access_log_bucket_id        = local.access_log_bucket_id
  admin_role                  = local.tf_admin_role
}

module "security_reports_frontend" {
  source = "./modules/ecs_task_pipeline"

  pipeline_name = "compliance-dataviz"
  src_repo      = "platsec-compliance-dataviz"
  branch        = "main"

  cluster_name = "security_reports_frontend"
  service_name = "compliance_dataviz"
  task_name    = "compliance_dataviz_task"
  ecr_url      = module.security_reports_frontend_repository.url
  ecr_arn      = module.security_reports_frontend_repository.arn

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
  access_log_bucket_id        = local.access_log_bucket_id
  admin_role                  = local.tf_admin_role
}

module "sandbox_aws_nuke" {
  source = "./modules/sandbox_lambda_docker_pipeline"

  pipeline_name = "sandbox-aws-nuke"
  src_repo      = "platsec-aws-nuke-lambda"
  branch        = "main"

  lambda_function_name = "go-nuke"
  ecr_arn              = module.go_nuke_repository.arn
  ecr_url              = module.go_nuke_repository.url

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
  access_log_bucket_id        = local.access_log_bucket_id
  admin_role                  = local.tf_admin_role
}

module "sandbox_compliance_alerting" {
  source = "./modules/sandbox_lambda_docker_pipeline"

  pipeline_name = "sandbox-compliance-alerting"
  src_repo      = "platsec-compliance-alerting"
  branch        = "sandbox"

  lambda_function_name = "platsec_compliance_alerting_lambda"
  ecr_arn              = module.compliance_alerting_repository.arn
  ecr_url              = module.compliance_alerting_repository.url

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
  access_log_bucket_id        = local.access_log_bucket_id
  admin_role                  = local.tf_admin_role
}

module "tf-s3-bucket-core" {
  source = "./modules/terraform_module_pipeline"

  pipeline_name = "terraform-aws-s3-bucket-core"
  src_repo      = "terraform-aws-s3-bucket-core"
  branch        = "main"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
  access_log_bucket_id        = local.access_log_bucket_id
  admin_role                  = local.tf_admin_role
}

module "tf-s3-bucket-standard" {
  source = "./modules/terraform_module_pipeline"

  pipeline_name = "terraform-aws-s3-bucket-standard"
  src_repo      = "terraform-aws-s3-bucket-standard"
  branch        = "main"

  test_timeout_in_minutes = 25

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
  access_log_bucket_id        = local.access_log_bucket_id
  admin_role                  = local.tf_admin_role
}

module "platsec-terraform-pipeline" {

  source = "./modules/platsec_terraform_pipeline"

  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
  access_log_bucket_id        = local.access_log_bucket_id
  admin_role                  = local.tf_admin_role

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

}
