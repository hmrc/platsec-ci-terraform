module "prowler_worker" {
  source = "./modules/lambda_docker_pipeline"

  pipeline_name = "prowler-worker"
  src_repo      = "platsec-prowler-lambda-worker"
  branch        = "main"
  github_token  = data.aws_secretsmanager_secret_version.github_token.secret_string

  lambda_function_name = "platsec_lambda_prowler_scanner"
  ecr_name             = "platsec-prowler"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
}

module "aws_scanner" {
  source = "./modules/lambda_docker_pipeline"

  pipeline_name = "aws-scanner"
  src_repo      = "platsec-aws-scanner"
  branch        = "main"

  lambda_function_name = "platsec_aws_scanner_lambda"
  ecr_name             = "platsec-aws-scanner"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
}

module "compliance_alerting" {
  source = "./modules/lambda_docker_pipeline"

  pipeline_name = "compliance-alerting"
  src_repo      = "platsec-compliance-alerting"
  branch        = "main"


  lambda_function_name = "platsec_compliance_alerting_lambda"
  ecr_name             = "platsec-compliance-alerting"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
}

module "cloudtrail_monitoring" {
  source = "./modules/lambda_zip_pipeline"

  pipeline_name = "cloudtrail-monitoring"
  src_repo      = "platsec-cloudtrail-monitoring"
  branch        = "main"
  github_token  = data.aws_secretsmanager_secret_version.github_token.secret_string

  lambda_function_name = "platsec_cloudtrail_monitoring"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
}

module "github_webhook_report" {
  source = "./modules/lambda_docker_pipeline"

  pipeline_name = "github-webhook-report"
  src_repo      = "github-webhook-report-lambda"
  branch        = "main"

  lambda_function_name = "github_webhook_report_lambda"
  ecr_name             = "github-webhook-report"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
}

module "compliance_dataviz" {
  source = "./modules/ecs_task_pipeline"

  pipeline_name = "compliance-dataviz"
  src_repo      = "platsec-compliance-dataviz"
  branch        = "main"

  ecr_name     = "platsec-compliance-dataviz"
  cluster_name = "security_reports_frontend"
  service_name = "compliance_dataviz"
  task_name    = "compliance_dataviz_task"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
}

module "sandbox_aws_nuke" {
  source = "./modules/sandbox_lambda_docker_pipeline"

  pipeline_name = "sandbox-aws-nuke"
  src_repo      = "platsec-aws-nuke-lambda"
  branch        = "main"

  lambda_function_name = "go-nuke"
  ecr_name             = "go-nuke"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
}

module "sandbox_compliance_alerting" {
  source = "./modules/sandbox_lambda_docker_pipeline"

  pipeline_name = "sandbox-compliance-alerting"
  src_repo      = "platsec-compliance-alerting"
  branch        = "sandbox"

  lambda_function_name = "platsec_compliance_alerting_lambda"
  ecr_name             = "platsec-compliance-alerting"

  accounts                    = local.accounts
  vpc_config                  = local.vpc_config
  ci_agent_to_internet_sg_id  = local.ci_agent_to_internet_sg_id
  ci_agent_to_endpoints_sg_id = local.ci_agent_to_endpoints_sg_id
  github_token                = data.aws_secretsmanager_secret_version.github_token.secret_string
  sns_topic_arn               = module.ci_alerts_for_production.sns_topic_arn
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
}
